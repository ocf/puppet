class ocf_mirrors::projects::pikvm {
  file {
    '/opt/mirrors/project/pikvm':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/pikvm/',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }
  ocf_mirrors::timer {
    'pikvm':
      exec_start => '/opt/mirrors/project/pikvm/sync-archive',
      hour       => '0/12',
      minute     => '30';
  }
}
