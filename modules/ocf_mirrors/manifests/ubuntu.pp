class ocf_mirrors::ubuntu {
  file {
    '/opt/mirrors/project/ubuntu':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/ubuntu/',
      owner   => mirrors,
      group   => mirrors,
      mode    => 755,
      recurse => true;
  }

  cron { 'ubuntu':
    command => '/opt/mirrors/project/ubuntu/sync-archive > /dev/null',
    user    => 'mirrors',
    hour    => '*/4',
    minute  => '15';
  }

  cron { 'ubuntu-releases':
    command => '/opt/mirrors/project/ubuntu/sync-releases > /dev/null',
    user    => 'mirrors',
    hour    => '*/7',
    minute  => '18';
  }
}
