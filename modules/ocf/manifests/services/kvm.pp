class ocf::services::kvm( $octet ) {

  # install kvm, libvirt, lvm, bridge networking
  ocf::repackage { [ 'bridge-utils', 'libvirt-bin', 'lvm2', 'netcat-openbsd', 'qemu-kvm', 'virtinst', 'virt-top' ]:
    recommends => false
  }

  # provide network interfaces
  file { '/etc/network/interfaces':
    content => template('ocf/services/kvm/interfaces.erb'),
    notify  => Service['networking']
  }
  # start network interfaces
  exec { 'ifup -a':
    refreshonly => true,
    subscribe   => File['/etc/network/interfaces']
  }

}
