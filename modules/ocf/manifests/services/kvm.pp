class ocf::services::kvm( $octet, $group = 'admin' ) {

  # install kvm, libvirt, lvm, bridge networking
  package { [ 'bridge-utils', 'libvirt-bin', 'lvm2', 'qemu-kvm', 'virtinst', 'virt-top' ]:
  }

  # provide network interfaces
  file { '/etc/network/interfaces':
    content     => template('ocf/services/kvm/interfaces.erb'),
    notify      => Service['networking']
  }
  # start network interfaces
  exec { 'ifup -a':
    refreshonly => true,
    subscribe   => File['/etc/network/interfaces']
  }

  # group access to libvirt
  augeas { '/etc/libvirt/libvirtd.conf':
    context   => "/files/etc/libvirt/libvirtd.conf",
    changes   =>  [
                    "set unix_sock_group $group",
                    'set unix_sock_rw_perms 0770'
                  ],
    require   => [ File['/etc/nsswitch.conf'], Package['libvirt-bin'] ]
  }
  service { 'libvirt-bin':
    subscribe => Augeas['/etc/libvirt/libvirtd.conf'],
    require   => Package['libvirt-bin']
  }

}
