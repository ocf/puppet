class ocf_mirrors::projects::rpmfusion {
  file {
    '/opt/mirrors/project/rpmfusion':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/rpmfusion',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'rpmfusion':
      exec_start => '/opt/mirrors/project/rpmfusion/sync-archive',
      hour       => '2/6',
      minute     => '15',
      require    => File['/opt/mirrors/project/rpmfusion'];
  }
}
