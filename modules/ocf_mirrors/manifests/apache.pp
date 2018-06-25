class ocf_mirrors::apache {
  file {
    '/opt/mirrors/project/apache':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/apache/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'apache':
    type          => 'unix_timestamp',
    upstream_host => 'archive.apache.org',
    upstream_path => '/dist',
    ts_path       => 'zzz/time.txt',
  }

  ocf_mirrors::timer {
    'apache':
      exec_start => '/opt/mirrors/project/apache/sync-archive',
      hour       => '0/8',
      minute     => '37';
  }
}
