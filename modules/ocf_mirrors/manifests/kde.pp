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

  ocf_mirrors::monitoring {
    'kde':
      type          => 'recursive_ls',
      upstream_host => 'download.kde.org',
      upstream_path => '',
      ts_path       => 'ls-lR';

    'kde-applicationdata':
      type          => 'unix_timestamp',
      upstream_host => 'files.kde.org',
      upstream_path => '',
      ts_path       => 'last-updated',
      filename     => 'health-appdata',
      project_path => '/opt/mirrors/project/kde';
  }

  cron {
    'kde':
      command => '/opt/mirrors/project/kde/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/2',
      minute  => '0',
  }
}
