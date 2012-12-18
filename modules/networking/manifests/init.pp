class networking($ipaddress = undef, $netmask = undef, $gateway = undef,
                 $bridge = false, $domain = undef, $nameservers = undef,) {

  class {
    'networking::interfaces':
      ipaddress   => $ipaddress,
      netmask     => $netmask,
      gateway     => $gateway,
      bridge      => $bridge,
    ;
    'networking::resolvconf':
      domain      => $domain,
      nameservers => $nameservers,
    ;
  }

  include networking::hostname

}
