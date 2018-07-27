class ocf::ssl::lets_encrypt::http {
  require ocf::ssl::setup

  package { ['acme-tiny', 'python3-openssl']:; }

  file {
    [
      '/var/lib/lets-encrypt/.well-known',
      '/var/lib/lets-encrypt/.well-known/acme-challenge',
    ]:
      ensure  => directory,
      owner   => ocfletsencrypt,
      group   => ssl-cert,
      require => Package['ssl-cert'];

    '/usr/local/bin/ocf-lets-encrypt':
      source  => 'puppet:///modules/ocf/ssl/ocf-lets-encrypt',
      mode    => '0755',
      require => Package['acme-tiny', 'python3-openssl'];
  }
}
