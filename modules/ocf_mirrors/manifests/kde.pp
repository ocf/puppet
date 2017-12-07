class ocf_mirrors::kde {
  file {
    '/opt/mirrors/project/kde':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/kde/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'kde':
      exec_start => '/opt/mirrors/project/kde/sync-archive > /dev/null',
      hour       => '0/2',
      minute     => '0',
  }
}
