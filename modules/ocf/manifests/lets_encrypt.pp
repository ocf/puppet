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

    [
      '/var/lib/lets-encrypt',
      '/var/lib/lets-encrypt/.well-known',
      '/var/lib/lets-encrypt/.well-known/acme-challenge',
    ]:
      ensure => directory,
      owner  => ocfletsencrypt,
      group  => sys;

    '/usr/local/bin/ocf-lets-encrypt':
      source => 'puppet:///modules/ocf/ssl/ocf-lets-encrypt',
      mode   => '0755';
  }
}
