class ocf_mirrors::puppetlabs {
  ocf_mirrors::ftpsync { 'puppetlabs':
    rsync_host  => 'rsync.puppet.com',
    rsync_path  => 'packages/apt',
    cron_minute => '55',
  }

  ocf_mirrors::monitoring { 'puppetlabs':
    type          => 'debian',
    dist_to_check => 'jessie',
    local_path    => '/puppetlabs/apt',
    upstream_host => 'apt.puppetlabs.com',
    upstream_path => '';
  }
}
