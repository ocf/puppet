class ocf::networking($ipaddress = undef, $netmask = undef, $gateway = undef,
  $bridge = false, $domain = undef, $nameservers = undef,
  ) {

  class {
    'ocf::networking::interfaces':
      ipaddress   => $ipaddress,
      netmask     => $netmask,
      gateway     => $gateway,
      bridge      => $bridge;

    'ocf::networking::resolvconf':
      domain      => $domain,
      nameservers => $nameservers;

    'ocf::networking::hostname':
      ipaddress   => $ipaddress;
  }


}
