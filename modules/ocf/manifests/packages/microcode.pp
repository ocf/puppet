class ocf::packages::microcode {
  if $facts['facts['processors']['models'][0]'] {
    if $facts['facts['processors']['models'][0]'] =~ /\bIntel\b/ {
      package { 'intel-microcode':; }
    } elsif $facts['facts['processors']['models'][0]'] =~ /\bAMD\b/ {
      package { 'amd64-microcode':; }
    } else {
      fail("Don't know how to interpret processor0: ${facts['facts['processors']['models'][0]']}")
    }
  }
}
