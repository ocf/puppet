class ocf_mirrors::projects::ubuntu_ports {
  ocf_mirrors::ftpsync { 'ubuntu-ports':
    rsync_host  => 'us.ports.ubuntu.com',
    cron_hour   => '0/6',
    cron_minute => '55';
  }
}
