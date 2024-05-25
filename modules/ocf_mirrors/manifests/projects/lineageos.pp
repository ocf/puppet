class ocf_mirrors::projects::lineageos {
  file {
    '/opt/mirrors/project/lineageos':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/lineageos',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'lineageos':
    type          => 'unix_timestamp',
    upstream_host => 'mirror.accum.se',
    ts_path       => 'mirror/lineageos/TIMESTAMP',
  }

  ocf_mirrors::timer {
    'lineageos':
      exec_start => '/opt/mirrors/project/lineageos/sync-archive',
      hour       => '0/6',
      minute     => '40';
  }
}
