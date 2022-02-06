class ocf_mirrors::projects::gentoo_distfiles {
  file {
    '/opt/mirrors/project/gentoo-distfiles':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gentoo-distfiles',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'gentoo-distfiles':
      exec_start => '/opt/mirrors/project/gentoo-distfiles/sync-archive',
      hour       => '3/6',
      minute     => '56',
      require    => File['/opt/mirrors/project/gentoo-distfiles'];
  }
}
