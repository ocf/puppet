class ocf_www::mod::php {
  include apache::mod::suphp

  package { 'php5-cgi':; }

  file { '/opt/suexec/php5-cgi':
    ensure  => link,
    target  => '/usr/bin/php5-cgi',
    require => Package['php5-cgi'],
  }

  # can't parse this with augeas because the PHP lens doesn't support weird
  # keys like "application/x-httpd-suphp" :\
  file { '/etc/suphp/suphp.conf':
    source  => 'puppet:///modules/ocf_www/apache/mods/suphp.conf',
    require => Package['libapache2-mod-suphp'],
    notify  => Service['apache2'];
  }

  apache::custom_config { 'php_suexec_options':
    content => "
      <Directory /opt/suexec/>
        SetHandler fastcgi-script
      </Directory>
    ",
  }
}
