class ocf_mirrors::projects::openeuler {
  file { '/opt/mirrors/project/openeuler':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/openeuler/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::timer {
    'openeuler':
      exec_start => '/opt/mirrors/project/openeuler/sync-archive',
      hour       => '0/12',
      minute     => '51';
  }
}
