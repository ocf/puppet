class ocf_mirrors::archlinux {
  file {
    '/opt/mirrors/project/archlinux':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/archlinux/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  cron {
    'archlinux':
      command => '/opt/mirrors/project/archlinux/sync-archive > /dev/null',
      user    => 'mirrors',
      hour    => '*/3',
      minute  => '22';
  }
}
