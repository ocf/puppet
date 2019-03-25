class ocf_desktop::dconf(String[1] $base_dir = '/etc/dconf') {
  file { $base_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
  }
}
