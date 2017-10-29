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

  # Service virtual host definitions
  ocf_mesos::master::load_balancer::http_vhost { 'rt':
    server_name    => 'rt.ocf.berkeley.edu',
    server_aliases => ['rt'],
    service_port   => 10001,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/rt/rt.crt',
    ssl_key        => '/opt/share/docker/secrets/rt/rt.key',
  }

  # Port 10002 is used by ocfweb-web

  ocf_mesos::master::load_balancer::http_vhost { 'pma':
    server_name    => 'pma.ocf.berkeley.edu',
    server_aliases => ['pma', 'phpmyadmin', 'phpmyadmin.ocf.berkeley.edu'],
    service_port   => 10003,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/pma/pma.ocf.berkeley.edu.crt',
    ssl_key        => '/opt/share/docker/secrets/pma/pma.ocf.berkeley.edu.key',
  }

  ocf_mesos::master::load_balancer::http_vhost { 'ocfweb-static':
    server_name    => 'static.ocf.berkeley.edu',
    service_port   => 10004,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/ocfweb/static.ocf.berkeley.edu.crt',
    ssl_key        => '/opt/share/docker/secrets/ocfweb/static.ocf.berkeley.edu.key',
  }

  ocf_mesos::master::load_balancer::http_vhost { 'templates':
    server_name    => 'templates.ocf.berkeley.edu',
    server_aliases => ['templates'],
    service_port   => 10007,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/templates/templates.ocf.berkeley.edu.crt',
    ssl_key        => '/opt/share/docker/secrets/templates/templates.ocf.berkeley.edu.key',
  }

  ocf_mesos::master::load_balancer::http_vhost { 'thelounge':
    server_name    => 'thelounge.ocf.berkeley.edu',
    server_aliases => ['thelounge'],
    service_port   => 10008,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/thelounge/thelounge.ocf.berkeley.edu.crt',
    ssl_key        => '/opt/share/docker/secrets/thelounge/thelounge.ocf.berkeley.edu.key',
  }

  ocf_mesos::master::load_balancer::http_vhost { 'metabase':
    server_name    => 'metabase.ocf.berkeley.edu',
    server_aliases => ['mb', 'metabase', 'mb.ocf.berkeley.edu'],
    service_port   => 10010,
    ssl            => true,
    ssl_cert       => '/opt/share/docker/secrets/metabase/metabase.ocf.berkeley.edu.crt',
    ssl_key        => '/opt/share/docker/secrets/metabase/metabase.ocf.berkeley.edu.key',
  }
}
