class ocf_mirrors::projects::fedora {
  ocf_mirrors::qfm {
    'epel':
      remote_host => 'rsync://dl.fedoraproject.org',
      cron_hour   => '0/6',
      cron_minute => '10';
  }

  ocf_mirrors::monitoring { 'epel':
    type          => 'http_last_modified',
    upstream_host => 'dl.fedoraproject.org',
    ts_path       => 'fullfiletimelist-epel',
    upstream_path => '/pub/epel',
    local_path    => '/fedora/epel';
  }

  ocf_mirrors::qfm {
    'enchilada':
      remote_host => 'rsync://mirrors.kernel.org',
      cron_hour   => '2/6',
      cron_minute => '20';
  }

  ocf_mirrors::monitoring { 'enchilada':
    type          => 'http_last_modified',
    upstream_host => 'dl.fedoraproject.org',
    ts_path       => 'fullfiletimelist-fedora',
    upstream_path => '/pub/fedora',
    local_path    => '/fedora/fedora';
  }
}
