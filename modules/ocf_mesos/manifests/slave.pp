class ocf_mesos::slave {
  include ocf::packages::docker
  include ocf_mesos::package

  package { 'chronos':
    ensure => purged;
  }

  augeas { '/etc/default/mesos-slave':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-slave',
    changes =>  [
      'set MASTER "hozer-70:5050"',
    ],
    notify  => Service['mesos-slave'],
    require => Package['mesos'];
  }

  File {
    notify    => Service['mesos-slave'],
    require   => Package['mesos'],
  }

  file {
    '/etc/mesos-slave/containerizers':
      content => "docker,mesos\n";
    # increase executor timeout in case we need to pull a Docker image
    '/etc/mesos-slave/executor_registration_timeout':
      content => "5mins\n";
  }
}
