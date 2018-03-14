class ocf_mirrors::kde_applicationdata {
  file {
    '/opt/mirrors/project/kde-applicationdata':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/kde-applicationdata/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring {
    'kde-applicationdata':
      type          => 'unix_timestamp',
      upstream_host => 'files.kde.org',
      upstream_path => '',
      ts_path       => 'last-updated';
  }

  cron {
    'kde-applicationdata':
      command => '/opt/mirrors/project/kde-applicationdata/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/2',
      minute  => '0',
  }
}
