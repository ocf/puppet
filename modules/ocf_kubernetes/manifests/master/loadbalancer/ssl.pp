# Provides the key, certificate, and Let's Encrypt CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}

class ocf_kubernetes::master::loadbalancer::ssl(
  String $vip,
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
  Array $domains = ['ocf.berkeley.edu', 'ocf.io'],
) {
  # Get all the cnames from the VIP
  $cnames = ldap_attr($vip, 'dnsCname', true)

  # TODO: get the domain name for the VIP and ensure that
  # is the first thing we pass to bundle, as that will
  # be the cn that the cert is issued for
  #
  # Do this after our rate-limit is lifted >.>

  $vfqdns = $cnames.map |$cname| {
    $domains.map |$domain| { "${cname}.${domain}" }
  }

  ocf::ssl::bundle { $::fqdn:
    domains => flatten($vfqdns),
    owner   => $owner,
    group   => $group,
  }
}
