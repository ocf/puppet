class ocf::packages::grub {
  # XXX: a bug in os-prober causes DATA CORRUPTION on OCF systems.
  #
  # Running `os-prober` on KVM hosts corrupts guest disks performing IO at the
  # same time.
  #
  # See rt#4268, rt#4245 for details.
  #
  # This is Debian bug#788062, which has been resolved, but we don't really
  # need os-prober anyway to detect other OSes since we don't have other OSes,
  # and we'd rather not have data corruption in the future:
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=788062
  if $::lsbdistid != 'Raspbian' {
    # grub-pc or grub-efi aren't available on Raspbian.
    if $::is_efi_host {
      ocf::repackage { 'grub-efi':
        recommends => false,
      }
    }
    else {
      ocf::repackage { 'grub-pc':
        recommends => false,
      }
    }
  }
  package { 'os-prober':
    ensure => purged;
  }
}
