class ocf_kvm($group = 'root') {
  include ocf::tmpfs

  # install kvm, libvirt, lvm, bridge networking
  package { ['libvirt-bin', 'qemu-kvm', 'virtinst', 'virt-top', 'ipmitool', 'kpartx']:; }
  include ocf::packages::lvm

  # group access to libvirt
  augeas {
    '/etc/libvirt/libvirtd.conf':
      context => '/files/etc/libvirt/libvirtd.conf',
      changes =>  [
                    "set unix_sock_group ${group}",
                    'set unix_sock_rw_perms 0770'
                  ],
      require => [ File['/etc/nsswitch.conf'], Package['libvirt-bin'] ],
      notify  => Service['libvirtd'];

    '/etc/libvirt/libvirt.conf':
      # libvirtd lens produces a validation error for this file
      lens    => 'Shellvars.lns',
      incl    => '/etc/libvirt/libvirt.conf',
      changes =>  ['set uri_default \'"qemu:///system"\''],
      require => Package['libvirt-bin'];
  }

  service { 'libvirtd':
    require => Package['libvirt-bin']
  }

  # makevm dependencies
  include ocf::packages::nmap

  file {
    '/usr/local/sbin/makevm':
      ensure => link,
      links  => manage,
      target => '/opt/share/utils/staff/sys/makevm';
  }
}
