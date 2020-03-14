class ocf_lb (
  Array[String] $vip_names,
  String $keepalived_secret_lookup,
  Integer[1, 255] $vrid,
) {
  $virtual_addresses_v4 = $vip_names.map |$vip| {
    ldap_attr($vip, 'ipHostNumber')
  }
  $virtual_addresses_v6 = $vip_names.map |$vip| {
    ldap_attr($vip, 'ip6HostNumber')
  }

  class { 'ocf_lb::keepalived':
    virtual_addresses_v4 => $virtual_addresses_v4,
    virtual_addresses_v6 => $virtual_addresses_v6,
    secret_lookup        => $keepalived_secret_lookup,
    vrid                 => $vrid,
  }

  class { 'ocf_lb::ssl':
    vips => $vip_names,
  }
}
