class ocf_mirrors::projects::libreelec {
  file {
    '/opt/mirrors/project/libreelec':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/libreelec/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'libreelec':
      exec_start => '/opt/mirrors/project/libreelec/sync-archive',
      hour       => '0/6'
      minute     => '17';
  }
}
