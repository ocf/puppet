class coupdetat {

  # prepare NAT networking
  file {
    # provide NAT DNS entries
    '/etc/hosts':
      source  => 'puppet:///modules/coupdetat/hosts',
    ;
    # provide libvirt NAT configuration
    '/etc/libvirt/qemu/networks/default.xml':
      source  => 'puppet:///modules/coupdetat/nat.xml',
    ;
    # provide NAT DNS resolution
    '/etc/resolv.conf':
      source  => 'puppet:///modules/coupdetat/resolv.conf',
    ;
    '/etc/sysctl.d/60-forward.conf':
      content => 'net.ipv4.ip_forward = 1',
      notify  => Service['procps'],
    ;
  }
  service { 'procps': }
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
  if $::operatingsystem == 'debian' {
    service { 'fuse':
        subscribe => [ Exec['fuse'], File[ '/usr/bin/fusermount', '/etc/fuse.conf' ] ],
        require   => [ Package['sshfs'],  ]
    }
  }

  # create pam_mkhomedir profile
  file { '/usr/share/pam-configs/mkhomedir':
    source  => 'puppet:///modules/ocf/desktop/pam/mkhomedir',
    notify  => Exec['pam-auth-update']
  }

}
