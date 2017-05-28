class ocf_www::site::vhosts {
  file {
    '/usr/local/bin/build-vhosts':
      source  => 'puppet:///modules/ocf_www/build-vhosts',
      mode    => '0755',
      require => [
        Package['python3-ocflib', 'python3-jinja2'],
        File['/opt/share/vhost-web.jinja'],
      ],
      notify  => Exec['build-vhosts'];

    '/opt/share/vhost-web.jinja':
      source  => 'puppet:///modules/ocf_www/vhost-web.jinja';

    '/etc/ssl/private/vhosts':
      ensure  => directory,
      source  => 'puppet:///private/ssl/vhosts',
      recurse => true,
      owner   => root,
      mode    => '0600';

    '/var/www/suexec':
      ensure  => directory,
      require => Package['httpd'];
  }

  cron { 'build-vhosts':
    command => 'chronic /usr/local/bin/build-vhosts web',
    special => hourly,
    require => File['/usr/local/bin/build-vhosts'],
  }

  exec { 'build-vhosts':
    command => '/usr/local/bin/build-vhosts web',
    creates => '/etc/apache2/ocf-vhost.conf',
    require => File['/usr/local/bin/build-vhosts'],
  }

  file { '/etc/apache2/sites-enabled/99-include-vhosts.conf':
    content => "
      # This kinda sucks, but we drop this in sites-enabled with priority 99
      # (instead of in conf.d) because the other vhosts must be included first.
      # (The first vhost declared is the fallback vhost.)
      Include /etc/apache2/ocf-vhost.conf
    ",
    require => Exec['build-vhosts'],
  }
}
