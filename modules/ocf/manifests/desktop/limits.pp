class ocf::desktop::limits {
  # provide process limits
  file { '/etc/security/limits.conf':
    source => 'puppet:///modules/ocf/desktop/limits.conf'
  }
}
