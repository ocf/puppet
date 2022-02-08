class ocf_www::mod::php {
  package { ['php-cgi', 'php-apcu']:; }

  $php_version = $::os['distro']['codename'] ? {
    'stretch' => '7.0',
    'buster'  => '7.3',
  }

  file { "/etc/php/${php_version}/cgi/conf.d/99-ocf.ini":
    source  => 'puppet:///modules/ocf_www/apache/mods/php/99-ocf.ini',
    require => Package['php-cgi'],
    notify  => Service['httpd'];
  }
}
