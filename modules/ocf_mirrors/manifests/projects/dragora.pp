class ocf_mirrors::projects::dragora {
  file {
    '/opt/mirrors/project/dragora':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/dragora',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'dragora':
      exec_start => '/opt/mirrors/project/dragora/sync-archive',
      hour       => '1/6',
      minute     => '26',
      require    => File['/opt/mirrors/project/dragora'];
  }
}
