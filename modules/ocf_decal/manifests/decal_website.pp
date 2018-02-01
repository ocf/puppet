class ocf_decal::decal_website {

  file {
    ['/srv/www', '/srv/www/decal']:
      ensure => directory,
      owner  => ocfdecal,
      group  => www-data,
      mode   => '0755',
      require => User['ocfdecal'];
  }

  apache::vhost { 'decal':
    servername => 'decal.ocf.berkeley.edu',
    serveraliases => [
      'decal.ocf.io',
      'decal.xcf.sh',
      'decal.xcf.berkeley.edu'
    ],
    port => 80,
    docroot => '/srv/www/decal',
    docroot_owner => 'ocfdecal',
    docroot_group => 'www-data',
  }
}
