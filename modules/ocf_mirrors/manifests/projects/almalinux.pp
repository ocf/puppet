class ocf_mirrors::projects::almalinux {
  file { '/opt/mirrors/project/almalinux':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/almalinux/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::timer {
    'almalinux':
      exec_start => '/opt/mirrors/project/almalinux/sync-archive',
      hour       => '2/4',
      minute     => '43';
  }
}
