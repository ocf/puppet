class ocf::local::fallout {

  # setup nat
  package { 'netstat-nat': }
  # Uncomment to enable net.ipv4.ip_forward in /etc/sysctl.conf
  file { '/etc/network/interfaces':
    source => 'puppet:///modules/ocf/local/fallout/interfaces',
    notify => [ Service['networking'], Exec['ifup -a'] ]
  }

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file { '/etc/dhcp/dhcpd.conf':
    source   => 'puppet:///modules/ocf/local/fallout/dhcpd.conf',
    require  => Package['isc-dhcp-server']
  }
  service { 'isc-dhcp-server':
    subscribe => File['/etc/dhcp/dhcpd.conf']
  }

}
