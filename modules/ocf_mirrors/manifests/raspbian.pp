class ocf_mirrors::raspbian {
  ocf_mirrors::ftpsync { 'raspbian':
    rsync_host               => 'archive.raspbian.org',
    rsync_path               => 'archive',
    cron_minute              => '45',
    monitoring_dist_to_check => 'jessie',
    monitoring_upstream_host => 'archive.raspbian.org';
  }
}
