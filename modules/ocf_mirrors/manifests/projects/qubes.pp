class ocf_mirrors::projects::qubes {
  file {
    '/opt/mirrors/project/qubes':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/qubes',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'qubes':
      exec_start => '/opt/mirrors/project/qubes/sync-archive',
      hour       => '5',
      minute     => '29',
      require    => File['/opt/mirrors/project/qubes'];
  }
}
