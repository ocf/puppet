class ocf_mirrors::projects::opnsense {
  file {
    '/opt/mirrors/project/opnsense':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/opnsense',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'opnsense':
      exec_start => '/opt/mirrors/project/opnsense/sync-archive',
      hour       => '1/6',
      minute     => '13',
      require    => File['/opt/mirrors/project/opnsense'];
  }
}
