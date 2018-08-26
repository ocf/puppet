class ocf_mesos::master::load_balancer($marathon_http_password) {
  include ocf::packages::docker

  file {
    '/opt/share/mesos/master/marathon-lb':
      ensure => directory;
    '/opt/share/mesos/master/marathon-lb/credential':
      mode      => '0600',
      content   => "marathon:${marathon_http_password}\n",
      show_diff => false;
  }

  ocf::systemd::service { 'ocf-lb':
    ensure  => running,
    source  => 'puppet:///modules/ocf_mesos/master/load_balancer/ocf-lb.service',
    enable  => true,
    require => Package['docker-ce'],
  }

  # keepalived config
  package { 'keepalived':; }
  $keepalived_secret = hiera('mesos::keepalived::secret')

  # Virtual addresses are owned by all of the mesos masters.
  # At a given time, only one master will actually have the IP, but
  # all masters are capable of holding the IP.
  #
  # Currently we have just a primary. Potentially other services which can't
  # use name-based hosts (e.g. SMTP or something) might need TCP forwarding,
  # and thus a different address.
  #
  # IPv6 addresses have to be specified separately as they cannot be in the vrrp
  # packet together (keepalived 1.2.20+) so they need to be in a
  # virtual_ipaddress_excluded block instead.
  $virtual_addresses = [
    # Primary load balancer IP (v4)
    '169.229.226.53',
  ]

  $virtual_addresses_v6 = [
    # Primary load balancer IP (v6)
    '2607:f140:8801::1:53',
  ]

  service { 'keepalived':
    require => Package['keepalived'],
  }

  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_mesos/master/load_balancer/keepalived.conf.erb'),
    mode    => '0400',
    require => Package['keepalived'],
    notify  => Service['keepalived'],
  }

  ocf::firewall::firewall46 { '101 accept on marathon-lb service ports':
    opts => {
      chain  => 'PUPPET-INPUT',
      proto  => 'tcp',
      dport  => '10000-10099',
      action => 'accept',
    },
  }

  ####################################
  # Service virtual host definitions #
  ####################################

  # Port 10000 is unused, it used to be used for fluffy, and then was used for
  # a trivial testing service, but is now unused again

  ocf_mesos::master::load_balancer::http_vhost { 'rt':
    server_name    => 'rt.ocf.berkeley.edu',
    server_aliases => ['rt'],
    service_port   => 10001,
  }

  # Port 10002 is used by ocfweb-web and proxied to by ocf_www

  ocf_mesos::master::load_balancer::http_vhost { 'pma':
    server_name    => 'pma.ocf.berkeley.edu',
    server_aliases => ['pma', 'phpmyadmin', 'phpmyadmin.ocf.berkeley.edu'],
    service_port   => 10003,
  }

  ocf_mesos::master::load_balancer::http_vhost { 'ocfweb-static':
    server_name  => 'static.ocf.berkeley.edu',
    service_port => 10004,
  }

  ocf_mesos::master::load_balancer::http_vhost { 'ircbot':
    server_name    => 'ircbot.ocf.berkeley.edu',
    server_aliases => ['ircbot'],
    service_port   => 10005,
  }

  ocf_mesos::master::load_balancer::http_vhost { 'metabase':
    server_name    => 'metabase.ocf.berkeley.edu',
    server_aliases => ['mb', 'metabase', 'mb.ocf.berkeley.edu'],
    service_port   => 10006,
  }

  ocf_mesos::master::load_balancer::http_vhost { 'templates':
    server_name    => 'templates.ocf.berkeley.edu',
    server_aliases => ['templates'],
    service_port   => 10007,
  }

  # Port 10008 is used by thelounge, it is proxied to by ocf_irc
  # Port 10009 is used by puppetboard, it is proxied to by ocf_puppet
  # Port 10010 cannot be used due to https://github.com/moby/moby/issues/37507

  ocf_mesos::master::load_balancer::http_vhost { 'grafana':
    server_name    => 'grafana.ocf.berkeley.edu',
    server_aliases => ['grafana'],
    service_port   => 10011,
  }

}
