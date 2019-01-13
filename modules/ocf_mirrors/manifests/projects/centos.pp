class ocf_mirrors::projects::centos {
  file { '/opt/mirrors/project/centos':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring {
    'centos':
      type          => 'unix_timestamp',
      upstream_host => 'mirror.centos.org',
      ts_path       => 'TIME';
  }

  ocf_mirrors::timer {
    'centos':
      exec_start => '/opt/mirrors/project/centos/sync-archive',
      hour       => '0/3',
      minute     => '22';
  }
}
