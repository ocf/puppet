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
    require => Package['docker-engine'],
  }

  # keepalived config
  package { 'keepalived':; }
  $keepalived_secret = 'hunter2'

  # Virtual addresses are owned by all of the mesos masters.
  # At a given time, only one master will actually have the IP, but
  # all masters are capable of holding the IP.
  #
  # Currently we have just a primary. Potentially other services which can't
  # use name-based hosts (e.g. SMTP or something) might need TCP forwarding,
  # and thus a different address.
  $virtual_addresses = [
    # Primary load balancer IP
    '169.229.226.53',
  ]

  service { 'keepalived':
    require => Package['keepalived'],
  }

  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_mesos/master/load_balancer/keepalived.conf.erb'),
    require => Package['keepalived'],
    notify  => Service['keepalived'],
  }

  # Service virtual host definitions
  ocf_mesos::master::load_balancer::http_vhost { 'fluffy':
    server_name  => ['fluffy.ocf.berkeley.edu'],
    service_port => 10000,
    ssl          => false,
  }
}
