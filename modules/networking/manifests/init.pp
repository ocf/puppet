class networking($ipaddress = undef, $netmask = undef, $gateway = undef,
  $bridge = false, $domain = undef, $nameservers = undef,
  $vlan = false,) {

  class {
    'networking::interfaces':
      ipaddress   => $ipaddress,
      netmask     => $netmask,
      gateway     => $gateway,
      bridge      => $bridge,
      vlan        => $vlan,
    ;
    'networking::resolvconf':
      domain      => $domain,
      nameservers => $nameservers,
    ;
  }

  include networking::hostname

}
