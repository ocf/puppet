class ocf_mirrors::projects::ipfire {
  file {
    '/opt/mirrors/project/ipfire':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/ipfire',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'ipfire':
      exec_start => '/opt/mirrors/project/ipfire/sync-archive',
      hour       => '1/6',
      minute     => '35',
      require    => File['/opt/mirrors/project/ipfire'];
  }
}
