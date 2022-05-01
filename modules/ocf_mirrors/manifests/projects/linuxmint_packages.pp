class ocf_mirrors::projects::linuxmint_packages {
  file {
    '/opt/mirrors/project/linuxmint-packages':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/linuxmint-packages',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring {
    'linuxmint-packages':
      type          => 'debian',
      dist_to_check => 'una',
      upstream_host => 'packages.linuxmint.com';
      upstream_path => '/';
  }

  ocf_mirrors::timer {
    'linuxmint-packages':
      exec_start => '/opt/mirrors/project/linuxmint-packages/sync-archive',
      hour       => '0/6',
      minute     => '40',
      require    => File['/opt/mirrors/project/linuxmint-packages'];
  }
}
