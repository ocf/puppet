class ocf::packages::memtest {
  if $::os['distro']['id'] != 'Raspbian' {
    package { 'memtest86+': }
  }
}
