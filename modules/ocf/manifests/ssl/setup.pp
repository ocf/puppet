# Provide the common certificates needed at the OCF.
# To build and deploy private keys, use the `ocf::ssl::bundle` type.
# (Or include `ocf::ssl::default` if you just want the default one that includes
# the FQDN and all aliases of a server.)

class ocf::ssl::setup {
  package { 'ssl-cert':; }

  user { 'ocfletsencrypt':
    groups     => ['ssl-cert', 'sys'],
    forcelocal => false,
  }

  file {
    default:
      # The ssl-cert package creates the ssl-cert group and the /etc/ssl/certs
      # and /etc/ssl/private directories (along with /etc/ssl if needed)
      require => Package['ssl-cert'];

    '/etc/ssl/certs/lets-encrypt.crt':
      source => 'puppet:///modules/ocf/ssl/lets-encrypt.crt',
      mode   => '0644';

    # 2048-bit dhparams for use by servers;
    # these are public numbers and can safely be shared across services
    '/etc/ssl/dhparam.pem':
      source => 'puppet:///modules/ocf/ssl/dhparam.pem',
      mode   => '0444';

    '/etc/ssl/lets-encrypt':
      ensure => directory,
      owner  => ocfletsencrypt;

    '/var/lib/lets-encrypt':
      ensure => directory,
      owner  => ocfletsencrypt,
      group  => ssl-cert;
  }

  ocf::privatefile { '/etc/ssl/lets-encrypt/le-account.key':
    content_path => '/opt/puppet/shares/private/lets-encrypt-account.key',
    owner        => ocfletsencrypt,
    mode         => '0400';
  }
}
