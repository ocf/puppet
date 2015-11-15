class ocf::networking::interfaces($ipaddress, $netmask, $gateway, $bridge) {
  file {
    '/etc/network/interfaces':
      content => template('ocf/networking/interfaces.erb');

    '/etc/network/if-up.d/ocf-vpn-route':
      ensure  => absent;
  }

  if $bridge {
    package { 'bridge-utils': }
  }
}
