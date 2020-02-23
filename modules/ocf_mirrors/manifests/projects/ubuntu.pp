class ocf_mirrors::projects::ubuntu {
  ocf_mirrors::ftpsync { 'ubuntu':
    rsync_host  => 'us.archive.ubuntu.com',
    cron_minute => '50';
  }

  ocf_mirrors::monitoring { 'ubuntu':
    type          => 'debian',
    dist_to_check => 'devel',
    upstream_host => 'archive.ubuntu.com';
  }
}
