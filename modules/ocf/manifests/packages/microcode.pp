class ocf::packages::microcode {
  if $::processors['models'][0] {
    if $::processors['models'][0] =~ /\bIntel\b/ {
      package { 'intel-microcode':; }
    } elsif $::processors['models'][0] =~ /\bAMD\b/ {
      package { 'amd64-microcode':; }
    } else {
      fail("Don't know how to interpret processor model: ${::processors['models'][0]}")
    }
  }
}
