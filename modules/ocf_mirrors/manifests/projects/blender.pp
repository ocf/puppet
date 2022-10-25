class ocf_mirrors::projects::blender {
  file {
    '/opt/mirrors/project/blender':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/blender',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }
  file {
    '/opt/mirrors/project/blender/sync_password':
        content   => lookup('mirrors::blender_sync_password'),
        show_diff => false,
        owner     => mirrors,
        group     => mirrors,
        mode      => '0400';
  }
  ocf_mirrors::timer {
    'blender':
      exec_start => '/opt/mirrors/project/blender/sync-archive',
      hour       => '5',
      minute     => '35',
      require    => File['/opt/mirrors/project/blender'];
  }
}
