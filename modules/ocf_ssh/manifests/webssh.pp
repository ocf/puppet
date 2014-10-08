class ocf_ssh::webssh {
  package {
    # Reverse proxy for shellinabox
    ['apache2']:
    ;

    # web ssh
    ['shellinabox']:
    ;
  }

  # apache must subscribe to all conf files
  service { 'apache2': }

  file { '/etc/apache2/sites-available/01-ssh.conf':
    ensure    => file,
    content   => template('ocf_ssh/apache/sites/ssh.conf.erb'),
    notify    => Service['apache2'],
    require   => [ Package['apache2'] ],
  }

  file { '/etc/apache2/sites-available/02-ssl.conf':
    ensure    => file,
    content   => template('ocf_ssh/apache/sites/ssl.conf.erb'),
    notify    => Service['apache2'],
    require   => [ Package['apache2'] ],
  }

  exec { '/usr/sbin/a2enmod rewrite':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load',
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }

  exec { '/usr/sbin/a2enmod ssl':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/ssl.load',
    notify      => Service['apache2'],
    require     => [ File["/etc/ssl/private/${::fqdn}.crt"], File["/etc/ssl/private/${::fqdn}.key"], Package['apache2'] ],
  }

  exec { '/usr/sbin/a2enmod proxy':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/proxy.load',
    notify      => Service['apache2'],
    require     => [ Package['apache2'] ],
  }

  exec { '/usr/sbin/a2enmod proxy_http':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/proxy_http.load',
    notify      => Service['apache2'],
    require     => [ Package['apache2'] ],
  }

  exec { '/usr/sbin/a2ensite 01-ssh.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/01-ssh.conf',
    notify      => Service['apache2'],
    require     => [Package['apache2'], Exec['/usr/sbin/a2enmod rewrite'], File['/etc/apache2/sites-available/01-ssh.conf']],
  }

  exec { '/usr/sbin/a2ensite 02-ssl.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/02-ssl.conf',
    notify      => Service['apache2'],
    require     => [Package['apache2'], Exec['/usr/sbin/a2enmod proxy'], Exec['/usr/sbin/a2enmod proxy_http'], File['/etc/apache2/sites-available/02-ssl.conf']],
  }
}
