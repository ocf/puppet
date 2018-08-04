class ocf_decal::website {
  include ocf::ssl::default
  include apache::mod::rewrite

  file {
    ['/srv/www', '/srv/www/decal']:
      ensure  => directory,
      owner   => ocfdecal,
      group   => www-data,
      mode    => '0755',
      require => User['ocfdecal'];
  }

  # Restart apache if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Apache::Service']

  apache::vhost { 'decal-http-redirect':
    servername      => 'decal.ocf.berkeley.edu',
    serveraliases   => [
      'decal',
      'decal.ocf.io',
      'decal.xcf.sh',
      'decal.xcf.berkeley.edu'
    ],

    port            => 80,
    docroot         => '/srv/www/decal',
    redirect_status => 'permanent',
    redirect_dest   => 'https://decal.ocf.berkeley.edu/',
  }

  apache::vhost { 'decal-canonical-redirect':
    servername      => 'decal.ocf.io',
    serveraliases   => [
      'decal',
      'decal.xcf.sh',
      'decal.xcf.berkeley.edu'
    ],

    port            => 443,
    docroot         => '/srv/www/decal',
    redirect_status => 'permanent',
    redirect_dest   => 'https://decal.ocf.berkeley.edu/',

    ssl             => true,
    ssl_key         => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert        => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain       => "/etc/ssl/private/${::fqdn}.intermediate",
}

  apache::vhost { 'decal-ssl':
    servername    => 'decal.ocf.berkeley.edu',

    port          => 443,
    docroot       => '/srv/www/decal',
    docroot_owner => 'ocfdecal',
    docroot_group => 'www-data',
    override      => ['All'],

    ssl           => true,
    ssl_key       => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain     => "/etc/ssl/private/${::fqdn}.intermediate",
  }
}
