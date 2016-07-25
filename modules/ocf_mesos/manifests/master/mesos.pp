class ocf_mesos::master::mesos($mesos_hostname) {
  include ocf_mesos::package

  $ocf_mesos_password = 'hunter2'

  file {
    '/etc/mesos-master':
      ensure  => directory,
      recurse => true,
      purge   => true,
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    '/etc/mesos-master/hostname':
      content => "${mesos_hostname}\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    # We have 3 servers, so 2 is a quorum.
    '/etc/mesos-master/quorum':
      content => "2\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    '/etc/mesos-master/work_dir':
      content => "/var/lib/mesos\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    [
      '/etc/mesos-master/authenticate',
      '/etc/mesos-master/authenticate_slaves',
      '/etc/mesos-master/authenticate_http',
    ]:
      content => "true\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    '/etc/mesos-master/authenticators':
      content => "crammd5\n",
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    '/etc/mesos-master/credentials':
      content => "/opt/share/mesos/master/credentials.json\n",
      require => [Package['mesos'], File['/opt/share/mesos/master/credentials.json']],
      notify  => Service['mesos-master'];

    '/opt/share/mesos/master/credentials.json':
      content   => template('ocf_mesos/master/mesos/credentials.json.erb'),
      mode      => '0400',
      show_diff => false,
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
