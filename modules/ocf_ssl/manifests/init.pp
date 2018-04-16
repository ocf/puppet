# TODO: rename this to ocf::ssl or something

# Provide the common certificates needed at the OCF.
# To build and deploy private keys, use the `ocf_ssl::bundle` type.
# (Or include `ocf_ssl::default_bundle` if you just want the default FQDN-based one.)
class ocf_ssl {
  package { 'ssl-cert':; }

  file {
    default:
      # the ssl-cert package creates the ssl-cert group
      require => Package['ssl-cert'];

    '/etc/ssl/certs/incommon-intermediate.crt':
      source => 'puppet:///modules/ocf_ssl/incommon-intermediate.crt',
      mode   => '0644';

    '/etc/ssl/certs/lets-encrypt.crt':
      source => 'puppet:///modules/ocf_ssl/lets-encrypt.crt',
      mode   => '0644';

    # 2048-bit dhparams for use by servers;
    # these are public numbers and can safely be shared across services
    '/etc/ssl/dhparam.pem':
      source => 'puppet:///modules/ocf_ssl/dhparam.pem',
      mode   => '0444';
  }
}
