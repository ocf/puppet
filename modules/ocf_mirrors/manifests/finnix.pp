class ocf_mirrors::finnix {
  file {
    '/opt/mirrors/project/finnix':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/finnix/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  cron {
    'finnix':
      command => '/opt/mirrors/project/finnix/sync-releases > /dev/null',
      user    => 'mirrors',
      hour    => '*/6',
      minute  => '41';
  }
}
