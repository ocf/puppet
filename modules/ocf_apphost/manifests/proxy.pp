class ocf_apphost::proxy {
  package { 'nginx':; }
  service { 'nginx':
    require => Package['nginx'];
  }

  file {
    '/etc/nginx/conf.d/local.conf':
      content => template('ocf_apphost/local.conf.erb'),
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/etc/nginx/sites-enabled/default':
      ensure  => file, # originally a link
      source  => 'puppet:///modules/ocf_apphost/default',
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/usr/local/bin/build-vhosts':
      source  => 'puppet:///modules/ocf_www/build-vhosts',
      mode    => '0755';

    '/opt/share/vhost-app.jinja':
      source  => 'puppet:///modules/ocf_apphost/vhost-app.jinja';

    # Generated SSL bundles go here
    '/etc/ssl/apphost':
      ensure  => directory,
      mode    => '0755';
  }

  $build_args = $::host_env ? {
    'dev'  => '--dev',
    'prod' => '',
  }

  cron {
    'build-vhosts':
      command => "chronic /usr/local/bin/build-vhosts ${build_args} app",
      minute  => '*/10',
      require => Package['nginx'];
  }
}
