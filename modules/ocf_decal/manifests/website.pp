class ocf_decal::website {

  file {
    ['/srv/www', '/srv/www/decal']:
      ensure  => directory,
      owner   => ocfdecal,
      group   => www-data,
      require => User['ocfdecal'];
    ['/srv/ssl', '/srv/ssl/decal']:
      ensure  => directory,
      owner   => ocfdecal,
      group   => www-data,
      mode    => '0440',
      require => User['ocfdecal'];
    '/srv/ssl/decal/decal.key':
      source  => 'puppet:///private/decal.key',
      mode    => '0440';

    '/srv/ssl/decal/decal.crt':
      source  => 'puppet:///private/decal.crt',
      mode    => '0440';

    '/etc/ssl/certs/lets-encrypt.crt':
      source  => 'puppet:///private/lets-encrypt.crt',
      mode    => '0640';
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

    port          => 443,
    docroot       => '/srv/www/decal',
    docroot_owner => 'ocfdecal',
    docroot_group => 'www-data',

    ssl       => true,
    ssl_key   => '/srv/ssl/decal/decal.key',
    ssl_cert  => '/srv/ssl/decal/decal.crt',
    ssl_chain => '/etc/ssl/certs/lets-encrypt.crt',
  }
}
