class ocf_lb::ssl(
  String $vip,
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
  Array $domains = ['ocf.berkeley.edu', 'ocf.io'],
) {
  # Get all the cnames from the VIP
  $cnames = ldap_attr($vip, 'dnsCname', true)

  $vfqdns = $cnames.map |$cname| {
    $domains.map |$domain| { "${cname}.${domain}" }
  }

  ocf::ssl::bundle { $::fqdn:
    domains => [$::fqdn] + flatten($vfqdns),
    owner   => $owner,
    group   => $group,
  }
}
