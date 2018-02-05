class ocf_decal::website {

  file {
    ['/srv/www', '/srv/www/decal']:
      ensure => directory,
      owner  => ocfdecal,
      group  => www-data,
      mode   => '0755',
      require => User['ocfdecal'];
  }

  apache::vhost { 'decal-redirect':
    servername => 'decal.ocf.berkeley.edu',
    serveraliases => [
      'decal.ocf.io',
      'decal.xcf.sh',
      'decal.xcf.berkeley.edu'
    ],
    port => 80,
    docroot => '/srv/www/decal',
    redirect_status => 'permanent',
    redirect_dest   => 'https://decal.ocf.berkeley.edu',
  }

  apache::vhost { 'decal-ssl':
    servername => 'decal.ocf.berkeley.edu',
    serveraliases => [
      'decal.ocf.io',
      'decal.xcf.sh',
      'decal.xcf.berkeley.edu',
    ],

    port => 443,
    docroot => '/srv/www/decal',
    docroot_owner => 'ocfdecal',
    docroot_group => 'www-data',

    ssl => true,
    ssl_key => '/etc/letsencrypt/keys/decal.key',
    ssl_cert => '/etc/ssl/certs/decal.crt',
    ssl_chain => '/etc/ssl/certs/lets-encrypt.crt',
  }
}
