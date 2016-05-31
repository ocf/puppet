class ocf_mesos::master::mesos($mesos_hostname) {
  include ocf_mesos::package

  file {
    '/etc/mesos/zk':
      ensure => absent,
      notify  => Service['mesos-master'],
      require => Package['mesos'];
    '/etc/mesos/hostname':
      content => "${mesos_hostname}\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];
  }

  augeas { '/etc/default/mesos-master':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-master',
    changes =>  [
      'set PORT 5050',
      'set ZK "zk://mesos0:2181,mesos1:2181,mesos2:2181/mesos"',
    ],
    notify  => Service['mesos-master'],
    require => Package['mesos'];
  }
}
