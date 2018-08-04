class ocf::packages::memtest {
  if $::lsbdistid != 'Raspbian' {
    package { 'memtest86+': }
  }
}
