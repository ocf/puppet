class ocf::packages::microcode {
  if !str2bool($::is_virtual)  {
    if $::processor0 =~ /\bIntel\b/ {
      package { 'intel-microcode':; }
    } elsif $::processor0 =~ /\bAMD\b/ {
      package { 'amd64-microcode':; }
    } else {
      fail("Don't know how to interpret processor0: ${::processor3}")
    }
  }
}
