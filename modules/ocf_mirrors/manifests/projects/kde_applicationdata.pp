class ocf_mirrors::projects::kde_applicationdata {
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

  ocf_mirrors::timer {
    'kde-applicationdata':
      exec_start => '/opt/mirrors/project/kde-applicationdata/sync-archive',
      hour       => '0/2',
      minute     => '0',
  }
}
