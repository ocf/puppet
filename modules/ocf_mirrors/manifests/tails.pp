class ocf_mirrors::tails {
  file {
    '/opt/mirrors/project/tails':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/tails/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'tails':
    type          => 'unix_timestamp',
    upstream_host => 'archive.torproject.org',
    upstream_path => '/amnesia.boum.org/tails',
    ts_path       => 'project/trace',
  }

  ocf_mirrors::timer {
    'tails':
      exec_start => '/opt/mirrors/project/tails/sync > /dev/null',
      minute     => '15';
  }
}
