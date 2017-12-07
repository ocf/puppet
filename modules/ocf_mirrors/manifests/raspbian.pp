class ocf_mirrors::raspbian {
  ocf_mirrors::ftpsync { 'raspbian':
    rsync_host  => 'archive.raspbian.org',
    rsync_path  => 'archive',
    cron_minute => '45',
    use_systemd => true,
  }

  ocf_mirrors::monitoring { 'raspbian':
    type          => 'debian',
    dist_to_check => 'jessie',
    local_path    => '/raspbian/raspbian',
    upstream_host => 'archive.raspbian.org';
  }
}
