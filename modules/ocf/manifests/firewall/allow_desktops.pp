# firewall input rule to allow desktops
class ocf::firewall::allow_desktops {
  $src_range_4 = lookup('desktop_src_range_4')
  $src_range_6 = lookup('desktop_src_range_6')

  firewall_multi {
    '101 accept input from desktops (IPv4)':
      chain     => 'PUPPET-INPUT',
      src_range => $src_range_4,
      proto     => 'tcp',
      action    => 'accept';

    '101 accept input from desktops (IPv6)':
      chain     => 'PUPPET-INPUT',
      src_range => $src_range_6,
      proto     => 'tcp',
      action    => 'accept',
      provider  => 'ip6tables';
  }
}
