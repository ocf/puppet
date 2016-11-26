# Provides the key, certificate, and InCommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle}
#
# Provides the InCommon intermediate chain at
# /etc/ssl/certs/incommon-intermediate.crt
class ocf_ssl::default_bundle {
  ocf_ssl::bundle { $::fqdn:; }
}
