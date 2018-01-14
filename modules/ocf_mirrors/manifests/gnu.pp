class ocf_mirrors::gnu {
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
    type          => 'ts',
    upstream_host => 'ftp.gnu.org',
    ts_path       => 'mirror-updated-timestamp.txt',
  }

  cron {
    'gnu':
      command => '/opt/mirrors/project/gnu/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/4',
      minute  => '38';
  }
}
