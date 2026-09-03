class ocf_www::lets_encrypt {
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
  }

  if $::host_env == 'prod' {
    # Run 5 minutes past the hour to allow for build-vhosts to be run so as
    # to minimize the time between a vhost being configured and getting HTTPS
    # enabled
    ocf::systemd::timer { 'lets-encrypt-update@web':
      service_source => 'puppet:///modules/ocf_www/lets-encrypt-update@.service',
      timer_source   => 'puppet:///modules/ocf_www/lets-encrypt-update@.timer',
      require        => [
        File['/usr/local/bin/lets-encrypt-update'],
        Ocf::Privatefile['/etc/ssl/lets-encrypt/le-vhost.key'],
      ],
    }

    cron { 'lets-encrypt-update':
      ensure => absent,
      user   => ocfletsencrypt,
    }
  }
}
