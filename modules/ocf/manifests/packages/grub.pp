class ocf::packages::grub {
  # XXX: a bug in os-prober causes DATA CORRUPTION on OCF systems.
  #
  # Running `os-prober` on KVM hosts corrupts guest disks performing IO at the
  # same time.
  #
  # See rt#4268, rt#4245 for details.
  #
  # This is (currently unresolved) Debian bug#788062
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=788062
  ocf::repackage { 'grub-pc':
    recommends => false;
  }
  package { 'os-prober':
    ensure => purged;
  }
}
