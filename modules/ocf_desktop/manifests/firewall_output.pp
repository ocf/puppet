#allow desktops to send packets to papercut, pagefault, radiation
class ocf_desktop::firewall_output {

  $devices = ['pagefault', 'papercut', 'radiation']

  $devices_ipv6 = ['radiation']

  $devices.each |String $d| {
    firewall { "899 allow desktop output to ${d} (IPv4)":
      chain       => 'PUPPET-OUTPUT',
      action      => 'accept',
      destination => $d,
    }
  }

  $devices_ipv6.each |String $d| {
    firewall { "899 allow desktop output to ${d} (IPv6)":
      chain       => 'PUPPET-OUTPUT',
      action      => 'accept',
      destination => $d,
      provider    => 'ip6tables',
    }
  }
}
