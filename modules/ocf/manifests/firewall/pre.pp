class ocf::firewall::pre {
  $firewall_defaults = {
    require => undef,
  }

  firewall_multi {
    default:
      * => $firewall_defaults;
    '000 accept all icmp':
      chain  => 'PUPPET-INPUT',
      proto  => 'icmp',
      action => 'accept';

    '000 accept all icmpv6':
      chain    => 'PUPPET-INPUT',
      proto    => 'ipv6-icmp',
      action   => 'accept',
      provider => 'ip6tables';
  }

  ocf::firewall::firewall46 {
    default:
      * => $firewall_defaults;

    '001 allow RELATED and ESTABLISHED traffic':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'all',
        'state'  => ['RELATED', 'ESTABLISHED'],
        'action' => 'accept',
      };
  }

  firewall_multi {
    default:
      * => $firewall_defaults;

    '002 allow ssh from desktops (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => '169.229.226.100-169.229.226.139',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';

    '002 allow ssh from desktops (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => '2607:f140:8801::1:100-2607:f140:8801::1:139',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';
  }

  firewall_multi {
    default:
      * => $firewall_defaults;

    '003 allow ssh from staff VMs (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => '169.229.226.200-169.229.226.252',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';

    '003 allow ssh from staff VMs (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => '2607:f140:8801::1:200-2607:f140:8801::1:252',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';
  }
}
