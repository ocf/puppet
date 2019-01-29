class ocf::etc {
  file { '/etc/ocf':
    ensure  => directory,
    source  => 'puppet:///etc',
    owner   => root,
    group   => root,
    mode    => '0755',
    purge   => true,
    recurse => true,
    backup  => false,
    force   => true,
  }
}
