class ocf::networking::interfaces($ipaddress, $netmask, $gateway, $bridge) {
  $newip = regsubst($ipaddress, '^169\.229\.10\.', '169.229.226.')
  $interface = $bridge ? {
    true    => 'br0',
    default => 'eth0',
  }

  file {
    '/etc/network/interfaces':
      content => template('ocf/networking/interfaces.erb');

    '/etc/network/if-up.d/ocf-vpn-route':
      content => template('ocf/networking/ocf-vpn-route.erb'),
      mode    => '0755';
  }

  if $bridge {
    package { 'bridge-utils': }
  }

  package { 'vlan': }
}
