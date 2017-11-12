class ocf::firewall::post {
  # Only allow root and postfix to connect to anthrax port 25; everyone else
  # must use the sendmail interface
  ['root', 'postfix'].each |$username| {
    ocf::firewall::firewall46 {
      "996 allow ${username} to send on SMTP port":
        opts => {
          chain  => 'PUPPET-OUTPUT',
          proto  => 'tcp',
          dport  => 'smtp',
          uid    => $username,
          action => 'accept',
        },
        before => undef,
    }
  }

  ocf::firewall::firewall46 {
    '997 forbid other users from sending on SMTP port':
      opts => {
        chain  => 'PUPPET-OUTPUT',
        proto  => 'tcp',
        dport  => 'smtp',
        action => 'drop',
      },
      before => undef,
  }


  # Special devices we want to protect from most hosts
  $devices = ['corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'pagefault', 'pandemic-mgmt',
              'papercut', 'radiation', 'riptide-mgmt']

  $devices_ipv6 = ['radiation']

  firewall { '998 allow all outgoing ICMP':
    chain  => 'PUPPET-OUTPUT',
    proto  => 'icmp',
    action => 'accept',
    before => undef,
  }

  firewall { '998 allow all outgoing ICMPv6':
    provider => 'ip6tables',
    chain    => 'PUPPET-OUTPUT',
    proto    => 'ipv6-icmp',
    action   => 'accept',
    before   => undef,
  }

  $devices.each |$d| {
    firewall { "999 drop other output to ${d} (IPv4)":
      chain       => 'PUPPET-OUTPUT',
      proto       => 'all',
      action      => 'drop',
      destination => $d,
      before      => undef,
    }
  }

  $devices_ipv6.each |$d| {
    firewall { "999 drop other output to ${d} (IPv6)":
      chain       => 'PUPPET-OUTPUT',
      proto       => 'all',
      action      => 'drop',
      destination => $d,
      provider    => 'ip6tables',
      before      => undef,
    }
  }
}
