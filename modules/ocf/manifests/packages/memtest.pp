class ocf::packages::memtest {
  # facter currently outputs strings not booleans
  # see http://projects.puppetlabs.com/issues/3704
  if str2bool($::is_virtual) {
    package { 'memtest86+':
      ensure => absent,
    }
  } else {
    package { 'memtest86+': }
  }
}
