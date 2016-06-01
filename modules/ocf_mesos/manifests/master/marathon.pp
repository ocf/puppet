class ocf_mesos::master::marathon($marathon_hostname) {
  include ocf_mesos::package

  package { 'marathon':; }

  ocf::systemd::service { 'marathon':
    ensure  => running,
    content => template('ocf_mesos/master/marathon/marathon.service.erb'),
    enable  => true,
    require => Package['marathon'],
  }
}
