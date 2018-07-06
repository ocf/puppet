class ocf_www::lets_encrypt {
  ocf::ssl::lets_encrypt { 'www':
    challenge_type => 'http',
  }

  file {
    '/usr/local/bin/lets-encrypt-update':
      source  => 'puppet:///modules/ocf_www/lets-encrypt-update',
      mode    => '0755',
      require => File['/usr/local/bin/ocf-lets-encrypt'];

    '/etc/ssl/lets-encrypt/le-vhost.key':
      source    => 'puppet:///private/lets-encrypt-vhost.key',
      owner     => ocfletsencrypt,
      show_diff => false,
      mode      => '0400';
  }

  if $::host_env == 'prod' {
    cron { 'lets-encrypt-update':
      command     => 'chronic /usr/local/bin/lets-encrypt-update -v web',
      user        => ocfletsencrypt,
      environment => ['MAILTO=root', 'PATH=/bin:/usr/bin:/usr/local/bin'],
      special     => hourly,
      require     => File['/usr/local/bin/lets-encrypt-update',
                          '/etc/ssl/lets-encrypt/le-vhost.key'],
    }
  }
}
