class ocf_mirrors::tanglu {
  ocf_mirrors::ftpsync { 'tanglu':
    rsync_host  => 'archive.tanglu.org',
    cron_minute => '40',
  }

  ocf_mirrors::monitoring { 'tanglu':
    type          => 'debian',
    dist_to_check => 'staging',
    upstream_host => 'archive.tanglu.org';
  }

  file { '/opt/mirrors/project/tanglu/sync-releases':
    source => 'puppet:///modules/ocf_mirrors/project/tanglu/sync-releases',
    mode   => '0755',
    owner  => mirrors,
    group  => mirrors;
  }

  ocf_mirrors::timer { 'tanglu-releases':
    exec_start => '/opt/mirrors/project/tanglu/sync-releases',
    hour       => '0/2',
    minute     => '53',
  }
}
