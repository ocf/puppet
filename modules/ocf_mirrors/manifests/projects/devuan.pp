class ocf_mirrors::projects::devuan {
  file {
    '/opt/mirrors/project/devuan':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/devuan',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

# Looks like devuan doesn't have a timestamp file, so omitted ocf_mirrors::monitoring

  ocf_mirrors::timer { 'devuan':
    exec_start => '/opt/mirrors/project/devuan/sync-archive',
    hour       => '0/6',
    minute     => '57',
    require    => File['/opt/mirrors/project/devuan'];
  }
}
