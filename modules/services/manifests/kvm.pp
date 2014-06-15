class services::kvm($group = 'ocfroot') {

  # install kvm, libvirt, lvm, bridge networking
  package { [ 'libvirt-bin', 'lvm2', 'qemu-kvm', 'virtinst', 'virt-top' ]:
  }

  # group access to libvirt
  augeas { '/etc/libvirt/libvirtd.conf':
    context   => '/files/etc/libvirt/libvirtd.conf',
    changes   =>  [
                    "set unix_sock_group $group",
                    'set unix_sock_rw_perms 0770'
                  ],
    require   => [ File['/etc/nsswitch.conf'], Package['libvirt-bin'] ],
    notify    => Service['libvirt-bin'],
  }
  service { 'libvirt-bin':
    require   => Package['libvirt-bin']
  }

  # ocf-makevm and dependencies
  file {
    "/usr/local/sbin/ocf-makevm":
      source => "puppet:///modules/services/kvm/ocf-makevm",
      owner => root,
      group => root,
      mode => 755;
  }

  package {
    ['python-colorama', 'python-paramiko']:;
  }
}
