class ocf_mirrors::projects::gimp {
  file {
    '/opt/mirrors/project/gimp':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gimp',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'gimp':
      exec_start => '/opt/mirrors/project/gimp/sync-archive',
      hour       => '0/6',
      minute     => '40',
      require    => File['/opt/mirrors/project/gimp'];
  }
}
