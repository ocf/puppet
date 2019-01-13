class ocf_mirrors::projects::gnu {
  file {
    '/opt/mirrors/project/gnu':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gnu/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'gnu':
    type          => 'unix_timestamp',
    upstream_host => 'ftp.gnu.org',
    ts_path       => 'mirror-updated-timestamp.txt',
  }

  ocf_mirrors::timer { 'gnu':
    exec_start => '/opt/mirrors/project/gnu/sync-archive',
    hour       => '0/4',
    minute     => '38',
  }
}
