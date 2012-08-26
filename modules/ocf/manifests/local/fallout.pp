class ocf::local::fallout {

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
