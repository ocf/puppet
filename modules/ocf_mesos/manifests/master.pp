class ocf_mesos::master {
  include ocf_mesos::chronos
  include ocf_mesos::master::docker_registry
  include ocf_mesos::master::pypi
  include ocf_mesos::package

  file {
    '/etc/mesos/zk':
      ensure => absent,
      notify  => Service['chronos', 'mesos-master'],
      require => Package['mesos'];
    '/etc/mesos/hostname':
      content => "mesos.ocf.berkeley.edu\n",
      notify  => Service['chronos', 'mesos-master'],
      require => Package['mesos'];
  }

  augeas { '/etc/default/mesos-master':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-master',
    changes =>  [
      'set PORT 5050',
      'rm ZK',
    ],
    notify  => Service['mesos-master'],
    require => Package['mesos'];
  }
}
