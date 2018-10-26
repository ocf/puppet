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

    '000 deny ipv6 router advertisement':
      chain    => 'PUPPET-INPUT',
      proto    => 'ipv6-icmp',
      action   => 'reject',
      icmp     => ['router-advertisement'],
      provider => 'ip6tables';

    '001 accept all icmpv6':
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

  $desktop_src_range_4 = lookup('desktop_src_range_4')
  $desktop_src_range_6 = lookup('desktop_src_range_6')

  firewall_multi {
    default:
      * => $firewall_defaults;

    '002 allow ssh from desktops (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => $desktop_src_range_4,
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';

    '002 allow ssh from desktops (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => $desktop_src_range_6,
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';
  }

  $staffvm_src_range_4 = lookup('staffvm_src_range_4')
  $staffvm_src_range_6 = lookup('staffvm_src_range_6')

  firewall_multi {
    default:
      * => $firewall_defaults;

    '003 allow ssh from staff VMs (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => $staffvm_src_range_4,
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';

    '003 allow ssh from staff VMs (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => $staffvm_src_range_6,
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';
  }
}
