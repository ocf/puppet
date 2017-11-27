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

  firewall_multi { '002 allow all SNS':
    chain  => 'PUPPET-INPUT',
    source => '128.32.30.64/27',
    action => 'accept',
    *      => $firewall_defaults,
  }

  # allow from supernova and hypervisors, hard code the addresses in case of DNS malfunction
  # ordering: [supernova, crisis, hal, jaws, pandemic, riptide]

  $allow_all = ['169.229.226.36', '169.229.226.7', '169.229.226.10', '169.229.226.12',
                '169.229.226.14', '169.229.226.16']

  $allow_all_v6 = ['2607:f140:8801::1:36', '2607:f140:8801::1:7', '2607:f140:8801::1:10',
                    '2607:f140:8801::1:12', '2607:f140:8801::1:14', '2607:f140:8801::1:16']

  $allow_all.each |String $s| {
    firewall_multi { "003 allow all from supernova and hypervisors (${s})":
      chain  => 'PUPPET-INPUT',
      action => 'accept',
      source => $s,
      *      => $firewall_defaults,
    }
  }

  $allow_all_v6.each |String $s| {
    firewall_multi { "003 allow all from supernova and hypervisors (${s})":
      chain    => 'PUPPET-INPUT',
      action   => 'accept',
      source   => $s,
      provider => 'ip6tables',
      *        => $firewall_defaults,
    }
  }

  firewall_multi {
    default:
      * => $firewall_defaults;

    '004 allow ssh from desktops (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => '169.229.226.100-169.229.226.139',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';

    '004 allow ssh from desktops (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => '2607:f140:8801::1:100-2607:f140:8801::1:139',
      proto     => 'tcp',
      dport     => 22,
      action    => 'accept';
  }

  ['munin', 'dev-munin'].each |$source| {
    ocf::firewall::firewall46 { "005 allow ${source} connections":
      *    => $firewall_defaults,
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'action' => 'accept',
        'dport'  => 'munin',
        'source' => $source,
        'proto'  => 'tcp',
      },
    }
  }
}
