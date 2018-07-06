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
        action      => 'reject',
      },
      before => undef,
  }

  # Special devices we want to protect from most hosts
  $devices_ipv4_only = lookup('devices_ipv4_only')
  $devices = lookup('devices_ipv46')

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

  firewall_multi { '999 reject output (special devices)':
    chain       => 'PUPPET-OUTPUT',
    proto       => 'all',
    action      => 'reject',
    destination => $devices_ipv4_only,
    before      => undef,
  }

  ocf::firewall::firewall46 { '999 reject output (special devices)':
    opts   => {
      chain       => 'PUPPET-OUTPUT',
      proto       => 'all',
      action      => 'reject',
      destination => $devices,
    },
    before => undef,
  }

  # reject from hosts in internal zone range but not actually internal
  if $ocf::firewall::reject_unrecognized_input {
    $reject_all = lookup('internal_zone_exceptions')
    ocf::firewall::firewall46 { '997 reject internal-zone-exception input':
      opts   => {
        chain  => 'PUPPET-INPUT',
        proto  => 'all',
        action => 'reject',
        source => $reject_all,
      },
      before => undef,
    }
  }

  # blanket-allow stuff from the internal zone
  $internal_zone_range_4 = lookup('internal_zone_range_4')
  $internal_zone_range_6 = lookup('internal_zone_range_6')
  firewall_multi {
    '998 allow from internal zone (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => $internal_zone_range_4,
      proto     => 'all',
      action    => 'accept',
      before    => undef;

    '998 allow from internal zone (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => $internal_zone_range_6,
      proto     => 'all',
      action    => 'accept',
      before    => undef;
  }

  # These rules intentionally apply only to addresses within our network as a reminder that
  # it is the external firewall's job to filter external packets.

  if $ocf::firewall::reject_unrecognized_input {
    firewall_multi {
      '999 reject unrecognized packets from within OCF network (IPv4)':
        chain  => 'PUPPET-INPUT',
        source => '169.229.226.0/24',
        proto  => 'all',
        action => 'reject',
        before => undef;

      '999 reject unrecognized packets from within OCF network (IPv6)':
        provider => 'ip6tables',
        chain    => 'PUPPET-INPUT',
        source   => '2607:f140:8801::/48',
        proto    => 'all',
        action   => 'reject',
        before   => undef;
    }
  }
}
