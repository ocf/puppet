class ocf_dns64 {
  require ocf::networking

  package { 'bind9':; }
  service { 'bind9':
    require => Package['bind9'];
  }

  $upstream_nameservers = $ocf::networking::nameservers
  $ocf_ipv6_mask = lookup('ocf_ipv6_mask')
  $decalvm_src_range_4 = lookup('decalvm_src_range_4')
  $decalvm_src_range_6 = lookup('decalvm_src_range_6')

  file {
    '/etc/bind/named.conf.options':
      content => template('ocf_dns64/named.conf.options.erb'),
      mode    => '0640',
      group   => bind,
      require => Package['bind9'],
      notify  => Service['bind9'];
  }

  firewall_multi {
    '101 allow dns (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => $decalvm_src_range_4,
      proto     => ['tcp', 'udp'],
      dport     => 53,
      action    => 'accept';

    '101 allow dns (IPv6)':
      provider  => 'ip6tables',
      chain     => 'PUPPET-INPUT',
      src_range => $decalvm_src_range_6,
      proto     => ['tcp', 'udp'],
      dport     => 53,
      action    => 'accept';
  }
}
