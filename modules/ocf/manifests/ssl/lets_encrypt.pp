define ocf::ssl::lets_encrypt(
    Enum['http', 'dns'] $challenge_type = 'dns',
) {
  file {
    '/etc/ssl/lets-encrypt':
      ensure    => directory;

    '/etc/ssl/lets-encrypt/le-account.key':
      content   => file('/opt/puppet/shares/private/lets-encrypt-account.key'),
      owner     => ocfletsencrypt,
      show_diff => false,
      mode      => '0400';
  }

  if $challenge_type == 'http' {
    package { ['acme-tiny', 'python3-openssl']:; }

    file {
      [
        '/var/lib/lets-encrypt',
        '/var/lib/lets-encrypt/.well-known',
        '/var/lib/lets-encrypt/.well-known/acme-challenge',
      ]:
        ensure => directory,
        owner  => ocfletsencrypt,
        group  => sys;

      '/usr/local/bin/ocf-lets-encrypt':
        source  => 'puppet:///modules/ocf/ssl/ocf-lets-encrypt',
        mode    => '0755',
        require => Package['acme-tiny', 'python3-openssl'];
    }
  } else {
    ocf::repackage { 'dehydrated':
      backport_on => stretch,
    }
    package { 'dehydrated-hook-ddns-tsig':; }
  }
}
