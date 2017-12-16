class ocf::firewall::post {
  # Only allow root and postfix to connect to anthrax port 25; everyone else
  # must use the sendmail interface
  ['root', 'postfix'].each |$username| {
    ocf::firewall::firewall46 {
      "996 allow ${username} to send on SMTP port":
        opts   => {
          chain  => 'PUPPET-OUTPUT',
          proto  => 'tcp',
          dport  => 25,
          uid    => $username,
          action => 'accept',
        },
        before => undef,
    }
  }

  ocf::firewall::firewall46 {
    '997 forbid other users from sending on SMTP port':
      opts   => {
        chain  => 'PUPPET-OUTPUT',
        proto  => 'tcp',
        dport  => 25,
        action => 'drop',
      },
      before => undef,
  }


  # Special devices we want to protect from most hosts
  $devices_ipv4_only = ['corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'pagefault',
                        'pandemic-mgmt', 'papercut', 'riptide-mgmt']
  $devices = ['radiation']

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

  $devices_ipv4_only.each |$d| {
    firewall { "999 drop other output to ${d}":
      chain       => 'PUPPET-OUTPUT',
      proto       => 'all',
      action      => 'drop',
      destination => $d,
      before      => undef,
    }
  }

  $devices.each |$d| {
    ocf::firewall::firewall46 { "999 drop other output to ${d}":
      opts   => {
        chain       => 'PUPPET-OUTPUT',
        proto       => 'all',
        action      => 'drop',
        destination => $d,
      },
      before => undef,
    }
  }
}
