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

  file { '/opt/mirrors/project/ubuntu/sync-releases':
    source => 'puppet:///modules/ocf_mirrors/project/ubuntu/sync-releases',
    mode   => '0755',
    owner  => mirrors,
    group  => mirrors;
  }

  ocf_mirrors::timer { 'ubuntu-releases':
    exec_start => '/opt/mirrors/project/ubuntu/sync-releases > /dev/null',
    hour       => '0/7',
    minute     => '18';
  }
}
