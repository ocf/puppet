class ocf::local::fallout2 {

  # setup nat
  package { 'netstat-nat': }
  # Uncomment to enable net.ipv4.ip_forward in /etc/sysctl.conf
  file { '/etc/network/interfaces':
    source => 'puppet:///modules/ocf/local/fallout2/interfaces',
    notify => Service['networking']
  }
  exec { 'ifup -a':
    refreshonly => true,
    subscribe   => File['/etc/network/interfaces']
  }

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file { '/etc/dhcp/dhcpd.conf':
    source   => 'puppet:///modules/ocf/local/fallout2/dhcpd.conf',
    require  => Package['isc-dhcp-server']
  }
  service { 'isc-dhcp-server':
    subscribe => File['/etc/dhcp/dhcpd.conf']
  }

}
