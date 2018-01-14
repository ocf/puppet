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
    type          => 'ts',
    upstream_host => 'archive.apache.org',
    upstream_path => '/dist',
    ts_path       => 'zzz/time.txt',
  }

  cron {
    'apache':
      command => '/opt/mirrors/project/apache/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/8',
      minute  => '37';
  }
}
