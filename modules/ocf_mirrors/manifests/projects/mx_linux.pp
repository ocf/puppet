class ocf_mirrors::projects::mx_linux {
  file {
    '/opt/mirrors/project/mx-linux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/mx-linux',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }
  file {
    '/opt/mirrors/project/mx-linux/sync_password':
        content   => lookup('mirrors::mx_linux_sync_password'),
        show_diff => false,
        owner     => mirrors,
        group     => mirrors,
        mode      => '0400';
  }
  ocf_mirrors::timer {
    'mx-linux':
      exec_start => '/opt/mirrors/project/mx-linux/sync-archive',
      hour       => '1/6',
      minute     => '35',
      require    => File['/opt/mirrors/project/mx-linux'];
  }
}
