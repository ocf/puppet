class ocf::firewall::post{


  $devices = ['corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'ocf-2.eac.berkeley.edu',
              'pagefault', 'pandemic-mgmt', 'papercut', 'radiation', 'riptide-mgmt']

  $devicesIPv6 = ['ocf-2.eac.berkeley.edu', 'radiation']

  #loop constructs rules to drop output to special devices

  $devices.each | String $d|{
    firewall { "998 drop output to ${d}":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      before      => undef,
    }
  }

  $devicesIPv6.each |String $d|{
    firewall { "998 drop output to ${d} (IPv6)":
      chain       => 'OUTPUT',
      action      => 'drop',
      destination => $d,
      provider    => 'ip6tables',
      before      => undef,
    }
  }

}
