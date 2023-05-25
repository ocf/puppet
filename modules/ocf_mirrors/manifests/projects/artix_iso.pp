class ocf_mirrors::projects::artix_iso {
  file {
    '/opt/mirrors/project/artix-iso':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/artix-iso',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'artix-iso':
      exec_start => '/opt/mirrors/project/artix-iso/sync-archive',
      hour       => '3/12',
      minute     => '30',
      require    => File['/opt/mirrors/project/artix-iso'];
  }
}
