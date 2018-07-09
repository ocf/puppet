# Provides the key, certificate, and Incommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle,intermediate}
#
# TODO: Remove this class once we are confident enough that using Let's Encrypt
# certs is working well and is sustainable
class ocf::ssl::default_incommon {
  ocf::ssl::bundle { $::fqdn:
    use_lets_encrypt => false,
  }
}
