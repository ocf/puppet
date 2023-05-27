class ocf_mirrors::projects::siduction {
  file {
    '/opt/mirrors/project/siduction':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/siduction',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'siduction':
    type          => 'unix_timestamp',
    upstream_host => 'packages.siduction.org',
    upstream_path => '/',
    ts_path       => 'TIME',
  }

  ocf_mirrors::timer {
    'siduction':
      exec_start => '/opt/mirrors/project/siduction/sync-archive',
      hour       => '1/6',
      minute     => '07',
      require    => File['/opt/mirrors/project/siduction'];
  }
}
