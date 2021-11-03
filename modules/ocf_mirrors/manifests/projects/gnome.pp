class ocf_mirrors::projects::gnome {
  file {
    '/opt/mirrors/project/gnome':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gnome/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  file {
    '/opt/mirrors/project/gnome/sync_password':
        content   => lookup('mirrors::gnome_sync_password'),
        show_diff => false,
        owner     => mirrors,
        group     => mirrors,
        mode      => '0400';
  }

  ocf_mirrors::timer {
    'gnome':
      exec_start => '/opt/mirrors/project/gnome/sync-archive',
      hour       => '2/4',
      minute     => '19';
  }
}
