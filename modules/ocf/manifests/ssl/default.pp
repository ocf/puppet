# Provides the key, certificate, and Let's Encrypt CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}
class ocf::ssl::default {
  # Attempt to collect all domains for a host to include in a SSL certificate.
  # The '@' record needs to be handled in a special case, since
  # "@.ocf.berkeley.edu" and "@.ocf.io" are both not valid domains
  if '@' in $::dnsA {
    $extra_domains = ['ocf.berkeley.edu', 'ocf.io']
  } else {
    $extra_domains = []
  }

  ocf::ssl::bundle { $::fqdn:
    domains => ocf::get_host_fqdns() + ocf::get_host_fqdns('ocf.io') + $extra_domains,
  }
}
