class ocf_www::mod::fpm {
  package { ['php-fpm']:; }

  file {
    '/usr/local/bin/build-fpm-pools':
      source => 'puppet:///modules/ocf_www/build-fpm-pools',
      mode   => '0755';

    '/opt/share/php-fpm-pool.jinja':
      source => 'puppet:///modules/ocf_www/php-fpm-pool.jinja';
  }
}
