class ocf_mesos::master::marathon {
  include ocf_mesos::package

  package { 'marathon':; }
  service { 'marathon':
    ensure  => running,
    enabled => true,
    require => [
      Package['marathon'],
      Service['mesos-master'],
    ],
  }
}
