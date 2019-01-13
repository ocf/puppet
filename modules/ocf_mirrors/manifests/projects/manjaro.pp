class ocf_mirrors::projects::manjaro {
  file {
    '/opt/mirrors/project/manjaro':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/manjaro/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::monitoring { 'manjaro':
    type          => 'manjaro',
    upstream_host => 'manjaro.mirrors.uk2.net',
    upstream_path => '',
    ts_path       => 'state',
  }

  # TODO: Change the rsync source to rsync://repo.manjaro.org/repos since we're
  # now an official mirror and should have access if we contact them about it.
  ocf_mirrors::timer {
    'manjaro':
      exec_start => '/opt/mirrors/project/manjaro/sync-archive',
      hour       => '0/2',
      minute     => '35';
  }
}
