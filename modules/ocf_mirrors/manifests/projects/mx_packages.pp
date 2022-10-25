class ocf_mirrors::projects::mx_packages {
  file {
    '/opt/mirrors/project/mx-packages':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/mx-packages',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }
  file {
    '/opt/mirrors/project/mx-packages/sync_password':
        content   => lookup('mirrors::mx_packages_sync_password'),
        show_diff => false,
        owner     => mirrors,
        group     => mirrors,
        mode      => '0400';
  }
  ocf_mirrors::timer {
    'mx-packages':
      exec_start => '/opt/mirrors/project/mx-packages/sync-archive',
      hour       => '1/2',
      minute     => '35',
      require    => File['/opt/mirrors/project/mx-packages'];
  }
}
