class ocf::etc {
  file { '/etc/ocf':
    ensure  => directory,
    source  => 'puppet:///etc',
    owner   => root,
    group   => root,
    purge   => true,
    recurse => true,
    backup  => false,
    force   => true,
  }
}
