class ocf_www::lets_encrypt {
  package { 'acme-tiny':; }

  file {
    '/usr/local/bin/lets-encrypt-update':
      source    => 'puppet:///modules/ocf_www/lets-encrypt-update',
      mode      => '0755';

    '/etc/ssl/lets-encrypt':
      ensure    => directory;

    '/etc/ssl/lets-encrypt/le-account.key':
      source    => 'puppet:///private/lets-encrypt-account.key',
      owner     => ocfletsencrypt,
      show_diff => false,
      mode      => '0400';

    '/etc/ssl/lets-encrypt/le-vhost.key':
      source    => 'puppet:///private/lets-encrypt-vhost.key',
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

  if $::hostname !~ /^dev-/ {
    cron { 'lets-encrypt-update':
      command     => 'chronic /usr/local/bin/lets-encrypt-update -v',
      user        => ocfletsencrypt,
      environment => 'MAILTO=root',
      special     => hourly,
      require     => File['/usr/local/bin/lets-encrypt-update'],
    }
  }
}
