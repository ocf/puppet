class common::limits {
  # provide process limits
  file { '/etc/security/limits.conf':
    source => 'puppet:///modules/common/limits.conf'
  }
}
