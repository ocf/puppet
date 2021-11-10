class ocf_mirrors::projects::ubuntu_ports {
  ocf_mirrors::ftpsync { 'ubuntu-ports':
    rsync_host  => 'us.ports.ubuntu.com',
    cron_hour   => '0/6',
    cron_minute => '55';
  }

  ocf_mirrors::monitoring { 'ubuntu-ports':
    type          => 'debian',
    dist_to_check => 'devel',
    upstream_host => 'ports.ubuntu.com',
    upstream_path => '';
  }
}
