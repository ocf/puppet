class ocf_www::mod::php {
  if $::lsbdistcodename == 'jessie' {
    package { ['php5-cgi', 'php5-apcu']:; }

    file { '/etc/php5/cgi/conf.d/99-ocf.ini':
      source  => 'puppet:///modules/ocf_www/apache/mods/php/99-ocf.ini',
      require => Package['php5-cgi'],
      notify  => Service['httpd'];
    }
  } else {
    package { ['php-cgi', 'php-apcu']:; }

    file { '/etc/php/7.0/cgi/conf.d/99-ocf.ini':
      source  => 'puppet:///modules/ocf_www/apache/mods/php/99-ocf.ini',
      require => Package['php-cgi'],
      notify  => Service['httpd'];
    }
  }
}
