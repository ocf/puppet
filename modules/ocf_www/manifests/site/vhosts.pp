class ocf_www::site::vhosts {
  file {
    '/usr/local/bin/build-vhosts':
      source  => 'puppet:///modules/ocf_www/build-vhosts',
      mode    => '0755',
      require => [
        Package['python3-ocflib', 'python3-jinja2'],
        File['/opt/share/vhost.jinja'],
      ],
      notify  => Exec['build-vhosts'];

    '/opt/share/vhost.jinja':
      source  => 'puppet:///modules/ocf_www/vhost.jinja';

    '/etc/ssl/private/vhosts':
      ensure  => directory,
      source  => 'puppet:///private/ssl/vhosts',
      recurse => true,
      owner   => root,
      mode    => '0600';

    '/var/www/suexec':
      ensure  => directory,
      require => Package['apache2'];
  }

  cron { 'build-vhosts':
    command => 'chronic /usr/local/bin/build-vhosts',
    special => hourly,
    require => File['/usr/local/bin/build-vhosts'],
  }

  exec { 'build-vhosts':
    command => '/usr/local/bin/build-vhosts',
    creates => '/etc/apache2/ocf-vhost.conf',
    require => File['/usr/local/bin/build-vhosts'],
  }

  apache::custom_config { 'include-vhosts':
    content => "
      Include /etc/apache2/ocf-vhost.conf
    ",
    priority => 99,
    require => Exec['build-vhosts'],
  }
}
