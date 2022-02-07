class ocf_mirrors::projects::rocky {
  file { '/opt/mirrors/project/rocky':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/rocky/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::timer {
    'rocky':
      exec_start => '/opt/mirrors/project/rocky/sync-archive',
      hour       => '1/3',
      minute     => '33';
  }
}
