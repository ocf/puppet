class ocf::firewall::post {
  require ocf::networking

  # Only allow root and postfix to connect to anthrax port 25; everyone else
  # must use the sendmail interface.
  # firewall-multi doesn't multiplex this so we have to do it manually :(
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
        chain       => 'PUPPET-OUTPUT',
        proto       => 'tcp',
        destination => ['anthrax', 'dev-anthrax'],
        dport       => 25,
        action      => 'drop',
      },
      before => undef,
  }


  # Special devices we want to protect from most hosts
  $devices_ipv4_only = [
    'corruption-mgmt','hal-mgmt', 'jaws-mgmt', 'logjam', 'pagefault',
    'pandemic-mgmt', 'papercut', 'riptide-mgmt',
  ]
  $devices = ['radiation']

  firewall_multi { '998 allow all outgoing ICMP':
    chain  => 'PUPPET-OUTPUT',
    proto  => 'icmp',
    action => 'accept',
    before => undef,
  }

  firewall_multi { '998 allow all outgoing ICMPv6':
    provider => 'ip6tables',
    chain    => 'PUPPET-OUTPUT',
    proto    => 'ipv6-icmp',
    action   => 'accept',
    before   => undef,
  }

  firewall_multi { '999 drop output (special devices)':
    chain       => 'PUPPET-OUTPUT',
    proto       => 'all',
    action      => 'drop',
    destination => $devices_ipv4_only,
    before      => undef,
  }

  ocf::firewall::firewall46 { '999 drop output (special devices)':
    opts   => {
      chain       => 'PUPPET-OUTPUT',
      proto       => 'all',
      action      => 'drop',
      destination => $devices,
    },
    before => undef,
  }


  # Drop packets on the primary network inteface that are not whitelisted
  # TODO: eliminate this if statement once testing is complete
  if $ocf::firewall::drop_other_input {
    ocf::firewall::firewall46 {
      '999 drop unrecognized input packets on primary interface':
        opts => {
          chain   => 'PUPPET-INPUT',
          proto   => 'all',
          iniface => $ocf::networking::iface,
          action  => 'drop',
        },
        before => undef,
    }
  }
}
