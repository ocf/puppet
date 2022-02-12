class ocf_mirrors::projects::gentoo_portage {
  file {
    '/opt/mirrors/project/gentoo-portage':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/gentoo-portage',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'gentoo-portage':
      exec_start => '/opt/mirrors/project/gentoo-portage/sync-archive',
      hour       => '*',
      minute     => '6/30',
      require    => File['/opt/mirrors/project/gentoo-portage'];
  }
}
