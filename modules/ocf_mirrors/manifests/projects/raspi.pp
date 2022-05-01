class ocf_mirrors::projects::raspi {
  file {
    '/opt/mirrors/project/raspi':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/raspi',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

 ocf_mirrors::monitoring { 'raspi':
    type          => 'debian',
    dist_to_check => 'bullseye',
    local_path    => '/raspi/debian',
    upstream_host => 'archive.raspberrypi.org',
    upstream_path => '/debian';
  }

  ocf_mirrors::timer {
    'raspi':
      exec_start => '/opt/mirrors/project/raspi/sync-archive',
      hour       => '*',
      minute     => '08',
      require    => File['/opt/mirrors/project/raspi'];
  }
}
