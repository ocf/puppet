class ocf::packages::memtest {
  if $facts['os']['distro']['id'] != 'Raspbian' {
    package { 'memtest86+': }
  }
}
