class ocf_mesos::master::marathon {
  include ocf_mesos::package

  package { 'marathon':; }

  ocf::systemd::service { 'marathon':
    ensure  => running,
    source  => 'puppet:///modules/ocf_mesos/master/marathon/marathon.service',
    enable  => true,
    require => Package['marathon'],
  }
}
