class ocf_mirrors::projects::parrot {
  file {
    '/opt/mirrors/project/parrot':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/parrot/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'parrot':
    type          => 'datetime',
    upstream_host => 'archive.parrotsec.org',
    ts_path       => 'last-sync.txt',
  }

  ocf_mirrors::timer {
    'parrot':
      exec_start => '/opt/mirrors/project/parrot/sync',
      minute     => '15',
      hour       => '0/3',
  }
}
