class ocf_mirrors::projects::linux_mint {
  file {
    '/opt/mirrors/project/linux-mint':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/linux-mint',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'linux-mint':
      exec_start => '/opt/mirrors/project/linux-mint/sync-archive',
      hour       => '0/12',
      minute     => '25',
      require    => File['/opt/mirrors/project/linux-mint'];
  }
}
