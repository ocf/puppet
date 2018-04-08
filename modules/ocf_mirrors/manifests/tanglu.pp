class ocf_mirrors::tanglu {
  ocf_mirrors::ftpsync { 'tanglu':
    rsync_host  => 'archive.tanglu.org',
    cron_minute => '40';
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

  cron { 'tanglu-releases':
    command => '/opt/mirrors/project/tanglu/sync-releases > /dev/null',
    user    => 'mirrors',
    hour    => '*/2',
    minute  => '53';
  }
}
