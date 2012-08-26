class ocf::local::fallout2 {

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file { '/etc/dhcp/dhcpd.conf':
    source   => 'puppet:///modules/ocf/local/fallout2/dhcpd.conf',
    require  => Package['isc-dhcp-server'],
    notify   => Service['isc-dhcp-server']
  }
  service { 'isc-dhcp-server':
    subscribe => File['/etc/dhcp/dhcpd.conf']
  }

}
