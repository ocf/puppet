# Provides the key, certificate, and Incommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}
class ocf::ssl::default_incommon {
  ocf::ssl::bundle { $::fqdn:
    intermediate_source => 'puppet:///modules/ocf/ssl/incommon-intermediate.crt',
  }
}
