class ocf::networking($ipaddress = undef, $netmask = undef, $gateway = undef,
  $bridge = false, $domain = undef, $nameservers = undef,
  $vlan = false,) {

  class {
    'ocf::networking::interfaces':
      ipaddress   => $ipaddress,
      netmask     => $netmask,
      gateway     => $gateway,
      bridge      => $bridge,
      vlan        => $vlan,
    ;
    'ocf::networking::resolvconf':
      domain      => $domain,
      nameservers => $nameservers,
    ;
  }

  include ocf::networking::hostname

}
