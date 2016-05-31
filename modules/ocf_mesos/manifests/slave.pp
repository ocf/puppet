class ocf_mesos::slave {
  include ocf::packages::docker
  include ocf_mesos::package
  include ocf_mesos::slave::secrets

  augeas { '/etc/default/mesos-slave':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-slave',
    changes =>  [
      'set MASTER "zk://mesos0:2181,mesos1:2181,mesos2:2181/mesos"',
    ],
    notify  => Service['mesos-slave'],
    require => Package['mesos'];
  }

  File {
    notify  => Service['mesos-slave'],
    require => Package['mesos'],
  }

  file {
    '/etc/mesos-slave/containerizers':
      content => "docker\n";
    # increase executor timeout in case we need to pull a Docker image
    '/etc/mesos-slave/executor_registration_timeout':
      content => "5mins\n";
    '/etc/mesos-slave/docker_remove_delay':
      content => "1secs\n";
  }
}
