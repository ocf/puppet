class ocf_mirrors::projects::kicad {
  file {
    '/opt/mirrors/project/kicad':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/kicad',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'kicad':
      exec_start => '/opt/mirrors/project/kicad/sync-archive',
      hour       => '0/12',
      minute     => '0';
  }
}
