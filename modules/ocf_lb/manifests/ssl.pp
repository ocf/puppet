# Provides the key, certificate, and Let's Encrypt CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}

class ocf_lb::ssl(
  Array[String] $vips,
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
  Array[String] $domains = ['ocf.berkeley.edu', 'ocf.io'],
) {
  $cnames = flatten($vips.map |$vip| {
    # Get all the cnames from the VIP
    ldap_attr($vip, 'dnsCname', true)
  })

  $vfqdns = $cnames.map |$cname| {
    $domains.map |$domain| { "${cname}.${domain}" }
  }

  ocf::ssl::bundle { $::fqdn:
    domains => [$::fqdn] + flatten($vfqdns),
    owner   => $owner,
    group   => $group,
  }
}
