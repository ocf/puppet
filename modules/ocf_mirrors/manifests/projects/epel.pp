class ocf_mirrors::projects::epel {
  file { '/opt/mirrors/project/epel':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_mirrors/project/epel/',
    owner   => mirrors,
    group   => mirrors,
    mode    => '0755',
    recurse => true,
  }
}