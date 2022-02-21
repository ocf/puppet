class ocf_mirrors::projects::sage {
  file {
    '/opt/mirrors/project/sage':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/sage',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'sage':
      exec_start => '/opt/mirrors/project/sage/sync-archive',
      hour       => '3',
      minute     => '05',
      require    => File['/opt/mirrors/project/sage'];
  }
}
