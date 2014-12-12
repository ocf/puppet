class common::memtest {
  # facter currently outputs strings not booleans
  # see http://projects.puppetlabs.com/issues/3704
  if $::is_virtual == 'false' {
    package { 'memtest86+': }
  } else {
    package { 'memtest86+':
      ensure => absent,
    }
  }
}
