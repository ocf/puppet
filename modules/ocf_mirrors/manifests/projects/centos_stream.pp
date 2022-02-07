class ocf_mirrors::projects::centos_stream {
  file { '/opt/mirrors/project/centos-stream':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/centos-stream/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring {
    'centos-stream':
      type          => 'unix_timestamp',
      upstream_host => 'mirror.stream.centos.org',
      upstream_path => '/',
      ts_path       => 'TIME';
  }

  ocf_mirrors::timer {
    'centos-stream':
      exec_start => '/opt/mirrors/project/centos-stream/sync-archive',
      hour       => '1/3',
      minute     => '33';
  }
}
