class ocf_mesos::master::mesos($mesos_hostname, $mesos_http_password) {
  include ocf_mesos::package

  $file_defaults = {
    notify  => Service['mesos-master'],
    require => Package['mesos'],
  }

  file {
    default:
      * => $file_defaults;

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

    [
      '/etc/mesos-master/authenticate',
      '/etc/mesos-master/authenticate_slaves',
      '/etc/mesos-master/authenticate_http_readonly',
      '/etc/mesos-master/authenticate_http_readwrite',
    ]:
      content => "true\n";

    '/etc/mesos-master/authenticators':
      content => "crammd5\n";

    '/etc/mesos-master/credentials':
      content => "/opt/share/mesos/master/credentials.json\n",
      require => File['/opt/share/mesos/master/credentials.json'];

    '/opt/share/mesos/master/credentials.json':
      content   => template('ocf_mesos/master/mesos/credentials.json.erb'),
      mode      => '0400',
      show_diff => false;
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
