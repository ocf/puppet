class ocf_mirrors::kde {
  file {
    '/opt/mirrors/project/kde':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/kde/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  cron {
    'kde':
      command => '/opt/mirrors/project/kde/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/2',
      minute  => '0',
  }
}
