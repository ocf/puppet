class ocf_mirrors::centos_altarch {
  file { '/opt/mirrors/project/centos-altarch':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos-altarch/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring {
    'centos-altarch':
      type          => 'unix_timestamp',
      upstream_host => 'mirror.centos.org',
      upstream_path => '/altarch',
      ts_path       => 'TIME';
  }

  cron {
    'centos-altarch':
      command => '/opt/mirrors/project/centos-altarch/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/3',
      minute  => '44';
  }
}
