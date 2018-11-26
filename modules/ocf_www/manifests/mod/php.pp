class ocf_www::mod::php {
  package { ['php-cgi', 'php-apcu']:; }

  file { '/etc/php/7.0/cgi/conf.d/99-ocf.ini':
    source  => 'puppet:///modules/ocf_www/apache/mods/php/99-ocf.ini',
    require => Package['php-cgi'],
    notify  => Service['httpd'];
  }
}
