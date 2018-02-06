class ocf_decal {

  include ocf_decal::website

  class { 'apache':
    default_vhost => false;
  }

  user { 'ocfdecal':
    comment => 'DeCal management account',
    home    => '/opt/ocfdecal',
    shell   => '/bin/bash',
    system  => true,
  }

  file { '/opt/ocfdecal':
    ensure => directory,
    owner => ocfdecal,
    group => ocfdecal,
    require => User['ocfdecal'];
  }
}
