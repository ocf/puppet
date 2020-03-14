# Provides the key, certificate, and Let's Encrypt CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}

class ocf_lb::ssl(
  Array[String] $vips,
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
  Array[String] $domains = ['ocf.berkeley.edu', 'ocf.io'],
) {
  $vips.map |$vip| {
    # Get all the cnames from the VIP
    $cnames = ldap_attr($vip, 'dnsCname', true)

    $vfqdns = flatten(([$vip] + $cnames).map |$cname| {
      $domains.map |$domain| { "${cname}.${domain}" }
    })

    ocf::ssl::bundle { $vfqdns[0]:
      domains => $vfqdns,
      owner   => $owner,
      group   => $group,
    }
  }
}
