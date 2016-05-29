class ocf_mesos::master::mesos {
  include ocf_mesos::package

  file {
    '/etc/mesos/zk':
      ensure => absent,
      notify  => Service['mesos-master'],
      require => Package['mesos'];
    '/etc/mesos/hostname':
      content => "${::hostname}\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];
  }

  augeas { '/etc/default/mesos-master':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-master',
    changes =>  [
      'set PORT 5050',
      'set ZK "zk://jaws:2181,pandemic:2181,hal:2181/mesos"',
    ],
    notify  => Service['mesos-master'],
    require => Package['mesos'];
  }
}
