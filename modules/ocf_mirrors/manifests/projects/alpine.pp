class ocf_mirrors::projects::alpine {
  file {
    '/opt/mirrors/project/alpine':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/alpine',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'alpine':
    type          => 'unix_timestamp',
    upstream_host => 'mirrors.alpinelinux.org',
    ts_path       => 'TIME',
  }

  ocf_mirrors::timer {
    'alpine':
      exec_start => '/opt/mirrors/project/alpine/sync-archive',
      hour       => '0/3',
      minute     => '22',
      require    => File['/opt/mirrors/project/alpine'];
  }
}
