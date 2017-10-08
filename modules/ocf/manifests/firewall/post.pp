class ocf::firewall::post {

  $devices = ['corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'pagefault', 'pandemic-mgmt',
              'papercut', 'radiation', 'riptide-mgmt']

  $devices_ipv6 = ['radiation']

  firewall { '998 allow all outgoing ICMP':
    chain  => 'OUTPUT',
    proto  => 'icmp',
    action => 'accept',
    before => undef,
  }

  firewall { '998 allow all outgoing ICMPv6':
    provider => 'ip6tables',
    chain    => 'OUTPUT',
    proto    => 'ipv6-icmp',
    action   => 'accept',
    before   => undef,
  }

  $devices.each |String $d| {
    firewall { "999 drop other output to ${d} (IPv4)":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      before      => undef,
    }
  }

  $devices_ipv6.each |String $d| {
    firewall { "999 drop other output to ${d} (IPv6)":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      provider    => 'ip6tables',
      before      => undef,
    }
  }
}
