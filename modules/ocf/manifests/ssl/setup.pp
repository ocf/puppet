# Provide the common certificates needed at the OCF.
# To build and deploy private keys, use the `ocf::ssl::bundle` type.
# (Or include `ocf::ssl::default` if you just want the default one that includes
# the FQDN and all aliases of a server.)
class ocf::ssl::setup {
  package { 'ssl-cert':; }

  file {
    default:
      # the ssl-cert package creates the ssl-cert group
      require => Package['ssl-cert'];

    '/etc/ssl/certs/incommon-intermediate.crt':
      source => 'puppet:///modules/ocf/ssl/incommon-intermediate.crt',
      mode   => '0644';

    '/etc/ssl/certs/lets-encrypt.crt':
      source => 'puppet:///modules/ocf/ssl/lets-encrypt.crt',
      mode   => '0644';

    # 2048-bit dhparams for use by servers;
    # these are public numbers and can safely be shared across services
    '/etc/ssl/dhparam.pem':
      source => 'puppet:///modules/ocf/ssl/dhparam.pem',
      mode   => '0444';
  }
}
