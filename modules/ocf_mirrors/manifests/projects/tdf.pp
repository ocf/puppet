class ocf_mirrors::projects::tdf {
  file {
    '/opt/mirrors/project/tdf':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/tdf',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'tdf':
    type          => 'unix_timestamp',
    upstream_host => 'download.documentfoundation.org',
    upstream_path => '/',
    ts_path       => 'TIMESTAMP',
  }

  ocf_mirrors::timer {
    'tdf':
      exec_start => '/opt/mirrors/project/tdf/sync-archive',
      hour       => '0/12',
      minute     => '20',
      require    => File['/opt/mirrors/project/tdf'];
  }
}
