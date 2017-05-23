class ocf_apphost::proxy($dev_config = false) {
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

    '/usr/local/sbin/build-vhosts':
      source  => 'puppet:///modules/ocf_www/build-vhosts',
      mode    => '0755';

    '/opt/share/vhost-app.jinja':
      source  => 'puppet:///modules/ocf_apphost/vhost-app.jinja';

    # Generated SSL bundles go here
    '/etc/ssl/apphost':
      ensure  => directory,
      mode    => '0755';
  }

  if $dev_config {
    $build_vhosts_cmd = 'chronic /usr/local/sbin/build-vhosts --dev app'
  } else {
    $build_vhosts_cmd = 'chronic /usr/local/sbin/build-vhosts app'
  }

  cron {
    'build-vhosts':
      command => $build_vhosts_cmd,
      minute  => '*/10',
      require => Package['nginx'];
  }
}
