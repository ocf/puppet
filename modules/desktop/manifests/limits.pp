class desktop::limits {
  # provide process limits
  file { '/etc/security/limits.conf':
    source => 'puppet:///modules/desktop/limits.conf'
  }
}
