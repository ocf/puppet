class ocf_mirrors::projects::freebsd {
  file {
    '/opt/mirrors/project/freebsd':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/freebsd',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'freebsd':
    type          => 'unix_timestamp',
    upstream_host => 'ftp.freebsd.org',
    upstream_path => '/pub/FreeBSD',
    ts_path       => 'TIMESTAMP';
  }

  ocf_mirrors::timer {
    'freebsd':
      exec_start => '/opt/mirrors/project/freebsd/sync-archive',
      hour       => '0/3',
      minute     => '35';
  }
}
