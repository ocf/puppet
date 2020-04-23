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
    upstream_host => 'dl-cdn.alpinelinux.org',
    ts_path       => 'last-updated',
  }

  ocf_mirrors::timer {
    'alpine':
      exec_start => '/opt/mirrors/project/alpine/sync-archive',
      hour       => '*',
      minute     => '42',
      require    => File['/opt/mirrors/project/alpine'];
  }
}
