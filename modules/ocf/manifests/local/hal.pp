class ocf::local::hal {

  # install kvm
  ocf::repackage { [ 'bridge-utils', 'libvirt-bin', 'lvm2', 'netcat-openbsd', 'qemu-kvm', 'virtinst', 'virt-top' ]:
    recommends => false
  }

  # provide bridge network interface
  file { '/etc/network/interfaces':
    source => 'puppet:///modules/ocf/local/hal/interfaces'
  }

}
