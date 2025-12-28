class ocf_mirrors::projects::termux {
  file {
    '/opt/mirrors/project/termux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/termux/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'termux':
    type          => 'unix_timestamp',
    upstream_host => 'packages.termux.dev',
    ts_path       => 'termux-main/lastupdate',
    upstream_path => '/apt',
    local_path    => '/termux';
  }

  ocf_mirrors::timer {
    'termux':
      exec_start => '/opt/mirrors/project/termux/sync-archive',
      hour       => '0/12',
      minute     => '30';
  }
}
