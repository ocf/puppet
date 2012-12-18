class networking::interfaces($ipaddress, $netmask, $gateway, $bridge) {

  file { '/etc/network/interfaces':
    content => template('networking/interfaces.erb'),
    notify  => Service['networking'],
  }

  service { 'networking': }

  if $bridge {
    package { 'bridge-utils': }
  }

}
