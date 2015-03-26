class ocf::limits {
  # provide process limits
  file { '/etc/security/limits.conf':
    source => 'puppet:///modules/ocf/limits.conf'
  }
}
