class ocf_apphost::proxy {
  package { 'nginx':; }
  service { 'nginx':
    require => [Package['nginx'], Exec['gen-dhparams']];
  }

  file {
    '/etc/nginx/conf.d/local.conf':
      source  => 'puppet:///modules/ocf_apphost/local.conf',
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/etc/nginx/sites-enabled/default':
      ensure  => file, # originally a link
      source  => 'puppet:///modules/ocf_apphost/default',
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/usr/local/sbin/rebuild-vhosts':
      source  => 'puppet:///modules/ocf_apphost/rebuild-vhosts',
      mode    => '0755';
  }

  exec {
    'gen-dhparams':
      command => 'openssl dhparam -out /etc/nginx/dhparam.pem 2048',
      creates => '/etc/nginx/dhparam.pem',
      require => Package['nginx'];
  }

  cron {
    'rebuild-vhosts':
      command => '/usr/local/sbin/rebuild-vhosts > /dev/null',
      minute  => '*/10',
      require => Package['nginx'];
  }
}
