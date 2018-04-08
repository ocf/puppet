class ocf_mesos::master::mesos(
    $mesos_hostname,
    $mesos_http_password,
    $masters,
    $zookeeper_uri,
) {
  include ocf_mesos::package

  # not using "/ 2" because it breaks syntax highlighting, lol
  $quorum = floor(size($masters) * 0.5) + 1

  file {
    default:
      notify  => Service['mesos-master'],
      require => Package['mesos'];

    '/etc/mesos-master':
      ensure  => directory,
      recurse => true,
      purge   => true;

    '/etc/mesos-master/hostname':
      content => "${mesos_hostname}\n";

    '/etc/mesos-master/quorum':
      content => "${quorum}\n";

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

  file { '/opt/share/mesos/master/zk':
    content   => "${zookeeper_uri}/mesos\n",
    mode      => '0400',
    show_diff => false,
    require   => Package['mesos'],
    notify    => Service['mesos-slave'],
  } ->
  augeas { '/etc/default/mesos-master':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-master',
    changes =>  [
      'set PORT 5050',
      "set ZK 'file:///opt/share/mesos/master/zk'",
    ],
    notify  => Service['mesos-master'],
    require => Package['mesos'];
  }
}
