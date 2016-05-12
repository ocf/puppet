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

  cron {
    'parrot':
      command => '/opt/mirrors/project/parrot/sync > /dev/null',
      user    => 'mirrors',
      minute  => '15',
      hour    => '*/3',
  }
}
