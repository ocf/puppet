class common::memtest {
  if $::is_virtual == false {
    package { 'memtest86+': }
  } else {
    package { 'memtest86+':
      ensure => absent,
    }
  }
}
