class ocf_mirrors::projects::videolan_ftp {
  file {
    '/opt/mirrors/project/videolan-ftp':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/videolan-ftp',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'videolan-ftp':
    ensure        => 'present',
    type          => 'unix_timestamp',
    upstream_host => 'ftp.videolan.org',
    ts_path       => 'trace';
  }

  ocf_mirrors::timer {
    'videolan-ftp':
      exec_start => '/opt/mirrors/project/videolan-ftp/sync-archive',
      hour       => '*',
      minute     => '24',
      require    => File['/opt/mirrors/project/videolan-ftp'];
  }
}
