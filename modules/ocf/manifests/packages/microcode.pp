class ocf::packages::microcode {
  if $facts['processors']['models'][0] {
    if $facts['processors']['models'][0] =~ /\bIntel\b/ {
      package { 'intel-microcode':; }
    } elsif $facts['processors']['models'][0] =~ /\bAMD\b/ {
      package { 'amd64-microcode':; }
    } else {
      fail("Don't know how to interpret processor0: ${facts['processors']['models'][0]}")
    }
  }
}
