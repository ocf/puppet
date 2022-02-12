class ocf_mirrors::projects::artix_linux {
  file {
    '/opt/mirrors/project/artix-linux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/artix-linux',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'artix-linux':
      exec_start => '/opt/mirrors/project/artix-linux/sync-archive',
      hour       => '3/4',
      minute     => '30',
      require    => File['/opt/mirrors/project/artix-linux'];
  }
}
