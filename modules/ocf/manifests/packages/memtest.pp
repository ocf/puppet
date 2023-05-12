class ocf::packages::memtest {
  if $facts['facts['os']['distro']['id']'] != 'Raspbian' {
    package { 'memtest86+': }
  }
}
