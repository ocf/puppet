class ocf_mirrors::projects::parabola {
  file {
    '/opt/mirrors/project/parabola':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/parabola/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'parabola':
    type          => 'unix_timestamp',
    upstream_host => 'repo.parabola.nu',
    ts_path       => 'lastsync',
  }

  ocf_mirrors::timer {
    'parabola':
      exec_start => '/opt/mirrors/project/parabola/sync-archive',
      hour       => '*',
      minute     => '48';
  }
}
