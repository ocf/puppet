class ocf::networking::interfaces($ipaddress, $netmask, $gateway, $bridge, $vlan) {

  file { '/etc/network/interfaces':
    content => template('ocf/networking/interfaces.erb'),
    notify  => Service['networking'],
  }

  service { 'networking': }

  if $bridge {
    package { 'bridge-utils': }
  }

  if $vlan {
    package { 'vlan': }
  }

}
