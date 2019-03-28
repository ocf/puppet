class ocf_mirrors::projects::openbsd {
  file {
    '/opt/mirrors/project/openbsd':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/openbsd',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'openbsd':
    type          => 'unix_timestamp',
    upstream_host => 'ftp.openbsd.org',
    upstream_path => '/pub/OpenBSD',
    ts_path       => 'timestamp';
  }

  ocf_mirrors::timer {
    'openbsd':
      exec_start => '/opt/mirrors/project/openbsd/sync-archive',
      hour       => '0/3',
      minute     => '30';
  }
}
