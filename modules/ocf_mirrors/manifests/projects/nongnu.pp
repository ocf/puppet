class ocf_mirrors::projects::nongnu {
  file {
    '/opt/mirrors/project/nongnu':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/nongnu',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'nongnu':
      exec_start => '/opt/mirrors/project/nongnu/sync-archive',
      hour       => '5/6',
      minute     => '46',
      require    => File['/opt/mirrors/project/nongnu'];
  }
}
