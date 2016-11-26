# Provides the key, certificate, and InCommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}
class ocf_ssl::default_bundle {
  ocf_ssl::bundle { $::fqdn:; }
}
