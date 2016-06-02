class ocf_mesos::master::marathon($marathon_hostname) {
  include ocf_mesos::package

  package { 'marathon':; }

  $ocf_mesos_password = 'hunter2'

  file {
    '/opt/share/mesos/master/marathon-secret':
      # XXX: cannot have final newline
      content   => $ocf_mesos_password,
      show_diff => false;
  }

  ocf::systemd::service { 'marathon':
    ensure  => running,
    content => template('ocf_mesos/master/marathon/marathon.service.erb'),
    enable  => true,
    require => [
      Package['marathon'],
      File['/opt/share/mesos/master/marathon-secret'],
    ];
  }
}
