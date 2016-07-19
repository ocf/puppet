# Provides the key, certificate, and InCommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle}
#
# Provides the InCommon intermediate chain at
# /etc/ssl/certs/incommon-intermediate.crt
class ocf_ssl($cert_name = $::fqdn) {
  File {
    owner   => root,
    group   => ssl-cert,

    # the ssl-cert package creates the ssl-cert group
    require => Package['ssl-cert']
  }

  package { 'ssl-cert':; }

  file {
    '/etc/ssl/certs/incommon-intermediate.crt':
      source  => 'puppet:///modules/ocf_ssl/incommon-intermediate.crt',
      mode    => '0644';

    '/etc/ssl/certs/lets-encrypt.crt':
      source  => 'puppet:///modules/ocf_ssl/lets-encrypt.crt',
      mode    => '0644';

    # 2048-bit dhparams for use by servers;
    # these are public numbers and can safely be shared across services
    '/etc/ssl/dhparam.pem':
      source  => 'puppet:///modules/ocf_ssl/dhparam.pem',
      mode    => '0444';


    # private ssl
    "/etc/ssl/private/${cert_name}.key":
      source  => "puppet:///private/ssl/${cert_name}.key",
      mode    => '0640';
    "/etc/ssl/private/${cert_name}.crt":
      source  => "puppet:///private/ssl/${cert_name}.crt",
      mode    => '0644';
  }

  # generate ssl bundle
  $bundle = "/etc/ssl/private/${cert_name}.bundle"

  concat { $bundle:
    owner => root,
    group => ssl-cert,
    mode  => '0644',

    ensure_newline => true;
  }

  concat::fragment {
    "${cert_name}-cert":
      target => $bundle,
      source => "puppet:///private/ssl/${cert_name}.crt",
      order  => '0';

    "${cert_name}-intermediate":
      target => $bundle,
      source => 'puppet:///modules/ocf_ssl/incommon-intermediate.crt',
      order  => '1';
  }
}
