class ocf_mirrors::centos_debuginfo {
  file { '/opt/mirrors/project/centos-debuginfo':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos-debuginfo/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring {
    'centos-debuginfo':
      type          => 'unix_timestamp',
      upstream_host => 'debuginfo.centos.org',
      upstream_path => '/',
      ts_path       => 'TIME';
  }

  cron {
    'centos-debuginfo':
      command => '/opt/mirrors/project/centos-debuginfo/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/3',
      minute  => '56';
  }
}
