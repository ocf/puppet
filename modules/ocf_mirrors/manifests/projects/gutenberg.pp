class ocf_mirrors::projects::gutenberg {
  file {
    '/opt/mirrors/project/gutenberg':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gutenberg',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'gutenberg':
      exec_start => '/opt/mirrors/project/gutenberg/sync-archive',
      hour       => '3/12',
      minute     => '02',
      require    => File['/opt/mirrors/project/gutenberg'];
  }
}
