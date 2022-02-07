class ocf_mirrors::projects::debian_nonfree {
  file {
    '/opt/mirrors/project/debian-nonfree':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/debian-nonfree',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'debian-nonfree':
      exec_start => '/opt/mirrors/project/debian-nonfree/sync-archive',
      hour       => '3',
      minute     => '52',
      require    => File['/opt/mirrors/project/debian-nonfree'];
  }
}
