class ocf::packages::kernel {
  if $::lsbdistcodename != 'stretch' {
    # Harden kernel using kernel command line options and sysctl settings
    # recommended by the Kernel Self Protection Project:
    # https://kernsec.org/wiki/index.php/Kernel_Self_Protection_Project/Recommended_Settings
    # Tails makes similar changes:
    # https://tails.boum.org/contribute/design/kernel_hardening/
    # kernel command line changes - potential performance impact:
    #  * always enable kernel address space layout randomization (KASLR)
    #  * always enable kernel page-table isolation (PTI, formerly KAISER)
    #  * wipe slab and page allocations and enable sanity checks
    #  * disable simultaneous multithreading (SMT) aka hyperthreading (HT)
    # sysctl changes:
    #  * disable kexec
    #  * restrict ptrace access to parent processes
    #  * disable user namespaces
    #    currently breaks systemd services specifying PrivateUsers=yes,
    #    such as upower on bullseye, see
    #    https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=959884
    #  * disable unprivileged Berkeley Packet Filter (BPF) access
    # For bullseye, also consider enabling the lockdown security module
    # introduced with Linux 5.4.
    package { 'hardening-runtime': }

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
