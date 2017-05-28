class ocf_apphost::lets_encrypt {
  include ocf::lets_encrypt

  file {
    '/usr/local/bin/lets-encrypt-update':
      source    => 'puppet:///modules/ocf_www/lets-encrypt-update',
      mode      => '0755';

    '/etc/ssl/lets-encrypt/le-vhost.key':
      source    => 'puppet:///private/lets-encrypt-vhost.key',
      owner     => ocfletsencrypt,
      show_diff => false,
      mode      => '0400';
  }

  if $::hostname !~ /^dev-/ {
    cron { 'lets-encrypt-update':
      command     => 'chronic /usr/local/bin/lets-encrypt-update -v app',
      user        => ocfletsencrypt,
      environment => 'MAILTO=root',
      special     => hourly,
      require     => File['/usr/local/bin/lets-encrypt-update',
                          '/etc/ssl/lets-encrypt/le-vhost.key'],
    }
  }
}
