class ocf_mirrors::projects::opensuse {
  file {
    '/opt/mirrors/project/opensuse':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/opensuse',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'opensuse':
      exec_start => '/opt/mirrors/project/opensuse/sync-archive',
      hour       => '1/6',
      minute     => '27',
      require    => File['/opt/mirrors/project/opensuse'];
  }
}
