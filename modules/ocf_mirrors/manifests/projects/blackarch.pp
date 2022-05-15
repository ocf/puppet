class ocf_mirrors::projects::blackarch {
  file {
    '/opt/mirrors/project/blackarch':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/blackarch/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'blackarch':
    type          => 'unix_timestamp',
    upstream_host => 'blackarch.org',
    upstream_path => '',
    ts_path       => 'lastupdate',
  }

  ocf_mirrors::timer {
    'blackarch':
      exec_start => '/opt/mirrors/project/blackarch/sync-archive',
      hour       => '0/2'
      minute     => '12';
  }
}
