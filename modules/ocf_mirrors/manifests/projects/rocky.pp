class ocf_mirrors::projects::rocky {
  file { '/opt/mirrors/project/rocky':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/rocky/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::monitoring { 'rocky':
    type          => 'http_last_modified',
    upstream_host => 'download.rockylinux.org',
    ts_path       => 'fullfiletimelist-rocky',
    upstream_path => '/pub/rocky',
  }

  ocf_mirrors::timer {
    'rocky':
      exec_start => '/opt/mirrors/project/rocky/sync-archive',
      hour       => '1/4',
      minute     => '33';
  }
}
