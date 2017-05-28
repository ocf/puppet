class ocf::lets_encrypt {
  package { 'acme-tiny':; }

  file {
    '/etc/ssl/lets-encrypt':
      ensure    => directory;

    '/etc/ssl/lets-encrypt/le-account.key':
      content   => file('/opt/puppet/shares/private/lets-encrypt-account.key'),
      owner     => ocfletsencrypt,
      show_diff => false,
      mode      => '0400';

    '/srv/well-known':
      ensure => directory;

    '/srv/well-known/acme-challenge':
      ensure => directory,
      owner  => ocfletsencrypt,
      group  => sys;
  }
}
