class ocf_mirrors::projects::osdn {
  file {
    '/opt/mirrors/project/osdn':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/osdn',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'osdn':
      exec_start => '/opt/mirrors/project/osdn/sync-archive',
      hour       => '*',
      minute     => '32',
      require    => File['/opt/mirrors/project/osdn'];
  }
}
