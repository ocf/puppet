class ocf_mirrors::projects::termux {
  file {
    '/opt/mirrors/project/termux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/termux/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }
  ocf_mirrors::timer {
    'termux':
      exec_start => '/opt/mirrors/project/termux/sync-archive',
      hour       => '0/12',
      minute     => '30';
  }
}
