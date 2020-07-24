class ocf::packages::kernel {
  if $::lsbdistcodename != 'stretch' {
    # Disable some kernel features: module loading after boot, kexec,
    # Berkeley Packet Filter (BPF). Not to be confused with the lockdown
    # security module introduced with Linux 5.4, which imposes similar
    # restrictions.
    package { 'lockdown': }

    if $::is_virtual {
      # Install cloud kernel image which removes some hardware support.
      # Benefits: slightly faster boot and reduced attack surface.
      package{ "linux-image-cloud-${::architecture}": }

      # Remove existing kernel meta-package. The actual kernel is its
      # dependency which should be autoremoved.
      package{ "linux-image-${::architecture}":
        ensure  => purged,
        require => Package["linux-image-cloud-${::architecture}"],
      }
    }
  }
}
