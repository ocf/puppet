class ocf::common::limits {
  # provide process limits
  file { '/etc/security/limits.conf':
    source => 'puppet:///modules/ocf/common/limits.conf'
  }
}
