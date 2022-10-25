class ocf_mirrors::projects::openwrt {
  file {
    '/opt/mirrors/project/openwrt':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/openwrt',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'openwrt':
      exec_start => '/opt/mirrors/project/openwrt/sync-archive',
      hour       => '3/6',
      minute     => '21',
      require    => File['/opt/mirrors/project/openwrt'];
  }
}
