class ocf_mirrors::projects::devuan {
  file {
    '/opt/mirrors/project/devuan':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/devuan',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'devuan':
    type          => 'unix_timestep',
    upstream_host => 'https://www.devuan.org/#download',
    ts_path       => 'TIME';
  }

  ocf_mirrors::timer { 'devuan':
    exec_start => '/opt/mirrors/project/devuan/sync-archive',
    hour       => '*',
    minute     => '57',
    require    => File['/opt/mirrors/project/devuan'];
  }
}
