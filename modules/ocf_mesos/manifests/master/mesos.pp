class ocf_mesos::master::mesos($mesos_hostname) {
  include ocf_mesos::package

  File {
    notify  => Service['mesos-master'],
    require => Package['mesos'],
  }

  file {
    '/etc/mesos-master':
      ensure  => directory,
      recurse => true,
      purge   => true;

    '/etc/mesos-master/hostname':
      content => "${mesos_hostname}\n";

    # We have 3 servers, so 2 is a quorum.
    '/etc/mesos-master/quorum':
      content => "2\n";

    '/etc/mesos-master/work_dir':
      content => "/var/lib/mesos\n";

    '/etc/mesos-master/authenticate_http':
      content => "false\n";
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
