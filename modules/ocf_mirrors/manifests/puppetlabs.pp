class ocf_mirrors::puppetlabs {
  ocf_mirrors::ftpsync { 'puppetlabs':
    rsync_host               => 'apt.puppetlabs.com',
    rsync_path               => 'packages/apt',
    cron_minute              => '55',
    monitoring_dist_to_check => 'jessie',
    monitoring_local_path    => 'puppetlabs/apt',
    monitoring_upstream_host => 'apt.puppetlabs.com',
    monitoring_upstream_path => '';
  }
}
