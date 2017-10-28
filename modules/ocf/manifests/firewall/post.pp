class ocf::firewall::post {

  $devices = ['corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'pagefault', 'pandemic-mgmt',
              'papercut', 'radiation', 'riptide-mgmt']

  $devicesIPv6 = ['radiation']

  $devices.each |String $d| {
    firewall { "998 allow ICMP to ${d} (IPv4)":
      chain       => 'OUTPUT',
      proto       => 'icmp',
      action      => 'accept',
      destination => $d,
      before      => undef,
    }
  }

  $devicesIPv6.each |String $d| {
    firewall { "998 allow ICMP to ${d} (IPv6)":
      chain       => 'OUTPUT',
      proto       => 'ipv6-icmp',
      action      => 'accept',
      destination => $d,
      provider    => 'ip6tables',
      before      => undef,
    }
  }

  $devices.each |String $d| {
    firewall { "999 drop other output to ${d} (IPv4)":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      before      => undef,
    }
  }

  $devicesIPv6.each |String $d| {
    firewall { "999 drop other output to ${d} (IPv6)":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      provider    => 'ip6tables',
      before      => undef,
    }
  }
}
