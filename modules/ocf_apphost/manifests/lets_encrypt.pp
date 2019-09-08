class ocf_apphost::lets_encrypt {
  include ocf::ssl::lets_encrypt::http

  file {
    '/usr/local/bin/lets-encrypt-update':
      source  => 'puppet:///modules/ocf_www/lets-encrypt-update',
      mode    => '0755',
      require => File['/usr/local/bin/ocf-lets-encrypt'];
  }

  ocf::privatefile { '/etc/ssl/lets-encrypt/le-vhost.key':
    source => 'puppet:///private/lets-encrypt-vhost.key',
    owner  => ocfletsencrypt,
    mode   => '0400',
    before => Cron['lets-encrypt-update'],
  }

  if $::host_env == 'prod' {
    cron { 'lets-encrypt-update':
      command     => 'chronic /usr/local/bin/lets-encrypt-update -v app',
      user        => ocfletsencrypt,
      environment => ['MAILTO=root', 'PATH=/bin:/usr/bin:/usr/local/bin'],
      special     => hourly,
      require     => File['/usr/local/bin/lets-encrypt-update'],
    }
  }
}
