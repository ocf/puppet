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
      exec_start => '/opt/mirrors/project/rocky/sync-archive > /dev/null 2>&1',
      hour       => '1/4',
      minute     => '33';
  }
}
