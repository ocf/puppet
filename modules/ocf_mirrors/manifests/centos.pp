class ocf_mirrors::centos {
  file { '/opt/mirrors/project/centos':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  cron {
    'centos':
      command => '/opt/mirrors/project/centos/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/3',
      minute  => '22';

    'centos-altarch':
      command => '/opt/mirrors/project/centos/sync-altarch > /dev/null',
      user    => 'mirrors',
      hour    => '*/3',
      minute  => '44';
  }
}
