# allow desktops to send packets to papercut, pagefault, radiation
class ocf_desktop::firewall_output {

  $devices_ipv4_only = ['pagefault', 'papercut']
  $devices = ['radiation']

  $devices_ipv4_only.each |String $d| {
    firewall { "899 allow desktop output to ${d}":
      chain       => 'PUPPET-OUTPUT',
      action      => 'accept',
      destination => $d,
    }
  }

  $devices.each |String $d| {
    ocf::firewall::firewall46 { "899 allow desktop output to ${d}":
      opts => {
        chain       => 'PUPPET-OUTPUT',
        action      => 'accept',
        destination => $d,
      },
    }
  }
}
