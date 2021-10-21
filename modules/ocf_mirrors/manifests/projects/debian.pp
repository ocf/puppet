class ocf_mirrors::projects::debian {
  ocf_mirrors::ftpsync {
    'debian':
      rsync_host  => 'mirrors.wikimedia.org',
      cron_hour   => '2/3',
      cron_minute => '30';

    'debian-security':
      rsync_host  => 'rsync.security.debian.org',
      cron_minute => '20';

    'debian-cd':
      rsync_host  => 'cdimage.debian.org',
      rsync_path  => 'debian-cd',
      rsync_extra => '--block-size=8192',
      cron_minute => '30';
  }

  ocf_mirrors::monitoring {
    'debian':
      type          => 'debian',
      dist_to_check => 'stable',
      upstream_host => 'ftp.us.debian.org';

    'debian-security':
      type          => 'debian',
      dist_to_check => 'stable/updates',
      upstream_host => 'security.debian.org',
      upstream_path => '';
  }
}
