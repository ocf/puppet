class ocf_mirrors::projects::raspbian {
  ocf_mirrors::ftpsync { 'raspbian':
    rsync_host  => 'ftp.halifax.rwth-aachen.de',
    rsync_path  => 'raspbian',
    cron_minute => '45',
  }

  ocf_mirrors::monitoring { 'raspbian':
    type          => 'debian',
    dist_to_check => 'bullseye',
    local_path    => '/raspbian/raspbian',
    upstream_host => 'archive.raspbian.org';
  }
}
