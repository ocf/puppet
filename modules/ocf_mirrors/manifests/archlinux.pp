class ocf_mirrors::archlinux {
  file {
    '/opt/mirrors/project/archlinux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/archlinux/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'archlinux':
    type          => 'unix_timestamp',
    upstream_host => 'mirrors.mit.edu',
    ts_path       => 'lastsync',
  }

  ocf_mirrors::timer {
    'archlinux':
      exec_start => '/opt/mirrors/project/archlinux/sync-archive',
      hour       => '0/3',
      minute     => '22';
  }
}
