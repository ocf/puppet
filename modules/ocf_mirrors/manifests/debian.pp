class ocf_mirrors::debian {
  ocf_mirrors::ftpsync {
    'debian':
      rsync_host               => 'mirrors.kernel.org',
      cron_minute              => '10',
      monitoring_dist_to_check => 'stable',
      monitoring_upstream_host => 'ftp.us.debian.org';

    'debian-security':
      rsync_host               => 'security.debian.org',
      cron_minute              => '20',
      monitoring_dist_to_check => 'stable/updates',
      monitoring_upstream_host => 'security.debian.org',
      monitoring_upstream_path => '';

    'debian-cd':
      rsync_host               => 'ftp.osuosl.org',
      rsync_path               => 'debian-cdimage',
      rsync_extra              => '--block-size=8192',
      cron_minute              => '30';
  }
}
