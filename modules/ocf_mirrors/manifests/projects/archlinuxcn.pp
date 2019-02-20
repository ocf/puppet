class ocf_mirrors::projects::archlinuxcn {
  file {
    '/opt/mirrors/project/archlinuxcn':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/archlinuxcn/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  file {
    '/opt/mirrors/project/archlinuxcn/sync_password':
        content   => lookup('mirrors::archlinuxcn_sync_password'),
        show_diff => false,
        owner     => mirrors,
        group     => mirrors,
        mode      => '0400';
  }

  ocf_mirrors::monitoring { 'archlinuxcn':
    type          => 'unix_timestamp',
    upstream_host => 'mirrors.tuna.tsinghua.edu.cn',
    upstream_path => 'archlinuxcn',
    ts_path       => 'lastupdate',
  }

  ocf_mirrors::timer {
    'archlinuxcn':
      exec_start => '/opt/mirrors/project/archlinuxcn/sync-archive',
      hour       => '0/4',
      minute     => '00';
  }
}
