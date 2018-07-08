# Provides the key, certificate, and Let's Encrypt CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}
class ocf::ssl::default {
  # Attempt to collect all domains for a host to include in a SSL certificate
  $domains = suffix(delete(concat(
    [$::hostname],
    $::dnsA,
    $::dnsCname,
  ), ''), '.ocf.berkeley.edu') + suffix(delete(concat(
    [$::hostname],
    $::dnsA,
    $::dnsCname,
  ), ''), '.ocf.io')

  ocf::ssl::bundle { $::fqdn:
    domains => $domains,
  }
}
