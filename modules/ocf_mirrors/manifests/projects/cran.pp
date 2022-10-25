class ocf_mirrors::projects::cran {
  file { '/opt/mirrors/project/cran':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/cran/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }

  ocf_mirrors::timer {
    'cran':
      exec_start => '/opt/mirrors/project/cran/sync-archive',
      hour       => '*',
      minute     => '20';
  }
}
