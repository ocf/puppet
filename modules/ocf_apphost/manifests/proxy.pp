class ocf_apphost::proxy {
  include ocf::ssl::default

  package { 'nginx':; }
  service { 'nginx':
    require   => Package['nginx'],
    subscribe => Class['ocf::ssl::default'],
  }

  file {
    '/etc/nginx/conf.d/local.conf':
      content => template('ocf_apphost/local.conf.erb'),
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/etc/nginx/sites-enabled/default':
      ensure  => file, # originally a link
      content => template('ocf_apphost/default-vhost.erb'),
      require => Package['nginx'],
      notify  => Service['nginx'];

    '/usr/local/bin/build-vhosts':
      source => 'puppet:///modules/ocf_www/build-vhosts',
      mode   => '0755';

    '/opt/share/vhost-app.jinja':
      source => 'puppet:///modules/ocf_apphost/vhost-app.jinja';

    # Generated SSL bundles go here
    '/etc/ssl/apphost':
      ensure => directory,
      mode   => '0755';
  }

  # TODO: Remove this once vampires has taken the place of werewolves and no
  # longer needs to be the dev host
  if $::hostname == 'vampires' {
    $build_args = '--dev'
  } else {
    $build_args = $::host_env ? {
      'dev'  => '--dev',
      'prod' => '',
    }
  }

  cron {
    'build-vhosts':
      command => "chronic /usr/local/bin/build-vhosts ${build_args} app",
      minute  => '*/10',
      require => [Package['nginx'], Class['ocf::ssl::default']];
  }
}
