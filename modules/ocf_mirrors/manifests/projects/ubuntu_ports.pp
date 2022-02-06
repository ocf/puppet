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

  file { '/opt/mirrors/project/ubuntu-ports/sync-releases':
    source => 'puppet:///modules/ocf_mirrors/project/ubuntu-ports/sync-releases',
    mode   => '0755',
    owner  => mirrors,
    group  => mirrors;
  }

  ocf_mirrors::timer { 'ubuntu-ports-releases':
    exec_start => '/opt/mirrors/project/ubuntu-ports/sync-releases > /dev/null',
    hour       => '0/7',
    minute     => '29';
  }
}
