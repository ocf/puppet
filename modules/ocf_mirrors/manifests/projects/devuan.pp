class ocf_mirrors::projects::devuan {
  file {
    '/opt/mirrors/project/devuan-cd':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/devuan-cd',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer { 'devuan-cd':
    exec_start => '/opt/mirrors/project/devuan-cd/sync-archive',
    hour       => '0/6',
    minute     => '57',
    require    => File['/opt/mirrors/project/devuan-cd'];
  }
}
