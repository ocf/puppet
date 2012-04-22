class ocf::local::coupdetat {

  # install kvm
  #ocf::repackage { [ 'bridge-utils', 'libvirt-bin', 'lvm2', 'netcat-openbsd', 'qemu-kvm', 'virtinst', 'virt-top' ]:
  #  recommends => false
  #}

  # install xen
  ocf::repackage { [ 'bridge-utils', 'dnsmasq-base', 'libvirt-bin', 'lvm2', 'netcat-openbsd', 'virtinst', 'virt-top', 'xen-linux-system-amd64', 'xen-utils-4.0' ]:
    recommends => false
  }

  # force xen kernel to be default
  file { '/etc/grub.d/09_linux_xen':
    ensure  => symlink,
    target  => '/etc/grub.d/20_linux_xen',
    require => Ocf::Repackage['xen-linux-system-amd64']
  }
  exec { 'update-grub2':
    refreshonly => true,
    subscribe   => File['/etc/grub.d/09_linux_xen']
  }

  # prepare NAT networking
  file {
    # provide libvirt NAT configuration
    '/etc/libvirt/qemu/networks/default.xml':
      source => 'puppet:///modules/ocf/local/coupdetat/nat.xml';
    # provide NAT DNS entries
    '/etc/hosts':
      source => 'puppet:///modules/ocf/local/coupdetat/hosts';
    # provide NAT DNS resolution
    '/etc/resolv.conf':
      source => 'puppet:///modules/ocf/local/coupdetat/resolv.conf'
  }
  # start NAT
  exec { 'virsh net-start':
    command     => 'virsh net-destroy default && virsh net-autostart default && virsh net-start default',
    refreshonly => true,
    subscribe   => File['/etc/libvirt/qemu/networks/default.xml','/etc/hosts']
  }

  # install pssh for parallel execution
  package { 'pssh': }

  # install sshfs
  package { 'sshfs':
  }
  # change fuse group to match ocf group gid
  exec { 'fuse':
    command => 'sed -i "s/^fuse:.*/fuse:x:20:/g" /etc/group',
    unless  => 'grep "fuse:x:20:" /etc/group',
    require => Package['sshfs']
  }
  file {
    '/usr/bin/fusermount':
      mode    => '4754',
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ];
    '/etc/fuse.conf':
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ]
  }
  service { 'fuse':
      subscribe => [ Exec['fuse'], File[ '/usr/bin/fusermount', '/etc/fuse.conf' ] ],
      require   => [ Package['sshfs'],  ]
  }

  # create pam_mkhomedir profile
  file { '/usr/share/pam-configs/mkhomedir':
    source  => 'puppet:///modules/ocf/desktop/pam/mkhomedir',
    notify  => Exec['pam-auth-update']
  }

}
