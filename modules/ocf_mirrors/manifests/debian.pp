class ocf_mirrors::debian {
  ocf_mirrors::ftpsync {
    'debian':
      rsync_host => 'mirrors.kernel.org',
      cron_minute => '10';

    'debian-security':
      rsync_host => 'security.debian.org',
      cron_minute => '20';

    'debian-cd':
      rsync_host  => 'ftp.osuosl.org',
      rsync_path  => 'debian-cdimage',
      rsync_extra => '--block-size=8192',
      cron_minute => '30';
  }

  file { '/opt/mirrors/project/debian/health':
    source  => 'puppet:///modules/ocf_mirrors/project/debian/health',
    mode    => '0755',
    owner   => mirrors,
    group   => mirrors;
  }

  cron { 'debian-health':
    command => '/opt/mirrors/project/debian/health',
    user    => 'mirrors',
    hour    => '*',
    minute  => '0';
  }
}
