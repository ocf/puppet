class ocf_mirrors::projects::lyx {
  file {
    default:
      owner => mirrors,
      group => mirrors;

    '/opt/mirrors/project/lyx':
      ensure => directory,
      mode   => '0755';

    '/opt/mirrors/project/lyx/sync-archive':
      source => 'puppet:///modules/ocf_mirrors/project/lyx/sync-archive',
      mode   => '0755';
  }

  ocf_mirrors::timer { 'lyx':
    exec_start => '/opt/mirrors/project/lyx/sync-archive',
    minute     => '30',
    hour       => '1',
  }
}
