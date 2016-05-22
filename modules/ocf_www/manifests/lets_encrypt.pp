class ocf_www::lets_encrypt {
  if $::hostname !~ /^dev-/ {
    package { 'acme-tiny':; }

    file {
      '/etc/ssl/private/lets-encrypt-account.key':
        source    => 'puppet:///private/lets-encrypt-account.key',
        show_diff => false,
        mode      => '0400';

      '/etc/ssl/private/lets-encrypt-vhost.key':
        source    => 'puppet:///private/lets-encrypt-vhost.key',
        show_diff => false,
        mode      => '0400';

      ['/srv/well-known', '/srv/well-known/acme-challenge']:
        ensure => directory;
    }
  }
}
