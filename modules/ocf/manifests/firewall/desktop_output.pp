#allow desktops to send packets to papercut, pagefault, radiation
class ocf::firewall::desktop_output {

  $devices = ['pagefault', 'papercut', 'radiation']

  $devices_ipv6 = ['radiation']

  $devices.each |String $d| {
    firewall { "899 allow desktop output to ${d} (IPv4)":
      chain       => 'PUPPET-OUTPUT',
      action      => 'accept',
      destination => $d,
      before      => 'post.pp',
    }
  }

  $devices_ipv6.each |String $d| {
    firewall { "899 allow desktop output to ${d} (IPv6)":
      chain       => 'PUPPET-OUTPUT',
      action      => 'accept',
      destination => $d,
      provider    => 'ip6tables',
      before      => 'post.pp',
    }
  }
}
