class ocf_mirrors::parrot {
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
    type          => 'ts',
    upstream_host => 'archive2.parrotsec.org',
    ts_path       => 'last-sync.txt',
  }

  cron {
    'parrot':
      command => '/opt/mirrors/project/parrot/sync > /dev/null',
      user    => 'mirrors',
      minute  => '15',
      hour    => '*/3',
  }
}
