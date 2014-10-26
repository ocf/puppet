class ocf_apphost::proxy {
  package { 'nginx':; }
  service { 'nginx':
    require => Package['nginx'];
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

  cron {
    'rebuild-vhosts':
      command => '/usr/local/sbin/rebuild-vhosts > /dev/null',
      minute  => '*/10',
      require => Package['nginx'];
  }
}
