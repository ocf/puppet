class ocf_mirrors::projects::videolan-ftp {
  file {
    '/opt/mirrors/project/videolan-ftp':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/videolan-ftp',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'alpine':
      exec_start => '/opt/mirrors/project/videolan-ftp/sync-archive',
      hour       => '*',
      minute     => '24',
      require    => File['/opt/mirrors/project/videolan-ftp'];
  }
}
