class ocf_mirrors::rasppi {
  ocf_mirrors::ftpsync { 'rasppi':
    rsync_host  => 'apt-repo.raspberrypi.org',
    rsync_path  => 'archive',
    cron_minute => '35';
  }

  ocf_mirrors::monitoring { 'rasppi':
    type          => 'debian',
    dist_to_check => 'stretch',
    local_path    => '/archive-raspberrypi/debian',
    upstream_path => '/debian',
    upstream_host => 'apt-repo.raspberrypi.org';
  }
}
