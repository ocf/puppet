class ocf_mirrors::projects::devuan {
  file {
    default:
      owner => mirrors,
      group => mirrors;

    '/opt/mirrors/project/devuan-cd':
      ensure => directory,
      mode   => '0755';

    '/opt/mirrors/project/devuan-cd/sync-releases':
      source => 'puppet:///modules/ocf_mirrors/project/devuan-cd/sync-archive',
      mode   => '0755';

    '/opt/mirrors/project/devuan':
      ensure => directory,
      mode   => '0755';

    '/opt/mirrors/project/devuan/sync-releases':
      source => 'puppet:///modules/ocf_mirrors/project/devuan/sync-archive',
      mode   => '0755';

    # we are registered with the Devuan project and have an SSH key for the
    # master upstream mirror
    '/opt/mirrors/project/devuan/devuan_rsa':
      source    => 'puppet:///private/mirrors/devuan',
      mode      => '0600',
      show_diff => false;
  }

  ocf_mirrors::timer {
    'devuan-cd':
      exec_start => '/opt/mirrors/project/devuan-cd/sync-archive',
      hour       => '0/6',
      minute     => '57',
      require    => File['/opt/mirrors/project/devuan-cd'];

    'devuan':
      exec_start => '/opt/mirrors/project/devuan/sync-archive',
      minute     => '3/30', # at 3 and 33th minute
      require    => File['/opt/mirrors/project/devuan'];
  }
}
