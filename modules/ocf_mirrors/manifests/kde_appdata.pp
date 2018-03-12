class ocf_mirrors::kde_appdata {
  file {
    '/opt/mirrors/project/kde-appdata':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/kde-appdata/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring {
    'kde-appdata':
      type          => 'unix_timestamp',
      upstream_host => 'files.kde.org',
      upstream_path => '',
      ts_path       => 'last-updated';
  }

  cron {
    'kde-appdata':
      command => '/opt/mirrors/project/kde-appdata/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/2',
      minute  => '0',
  }
}
