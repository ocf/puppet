class ocf_mirrors::projects::qt {
  file {
    '/opt/mirrors/project/qt':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/qt/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'qt':
    type          => 'unix_timestamp',
    upstream_host => 'download.qt.io',
    upstream_path => '',
    ts_path       => 'timestamp.txt',
  }

  ocf_mirrors::timer {
    'qt':
      exec_start => '/opt/mirrors/project/qt/sync-archive',
      hour       => '0/4',
      minute     => '5',
  }
}
