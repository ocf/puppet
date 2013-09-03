class tsunami {

  # Create directories to mount on
  file {
    '/services':
      ensure  => directory;
    '/home':
      ensure  => directory;
    '/opt/ocf':
      ensure  => directory;
    '/var/mail':
      ensure  => directory,
      owner   => 'root',
      group   => 'disk',
      mode    => '1777';
    '/etc/pykota':
      ensure  => directory,
      owner   => 'nobody',
      group   => 'nogroup',
      mode    => '0755';
    '/opt/httpd':
      ensure  => directory,
      group   => 'adm';
  }

  mount {
    '/services':
      ensure  => 'mounted',
      require => File[ '/services' ],
      device  => 'services:/services',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'rw,bg,noatime,nodev,nosuid';
    '/home':
      ensure  => 'mounted',
      require => File[ '/home' ],
      device  => 'homes:/home',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'rw,bg,noatime,nodev,nosuid';
    '/opt/ocf':
      ensure  => 'mounted',
      require => File[ '/opt/ocf' ],
      device  => 'opt:/i686-real',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'ro,bg,noatime,nodev,nosuid';
    '/var/mail':
      ensure  => 'mounted',
      require => File[ '/var/mail' ],
      device  => 'mailbox:/',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'rw,bg,noatime,nodev,nosuid';
    '/etc/pykota':
      ensure  => 'mounted',
      require => File[ '/etc/pykota' ],
      device  => 'printhost:/',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'ro,bg,noatime,nodev,nosuid';
    '/opt/httpd':
      ensure  => 'mounted',
      require => File[ '/opt/httpd' ],
      device  => 'www:/',
      fstype  => 'nfs4',
      atboot  => true,
      options => 'ro,bg,noatime,nodev,nosuid';
  }

  package {
    # Reverse proxy for shellinabox
    ['apache2']:
    ;

    # web ssh
    ['shellinabox']:
    ;
  }

  # Provide SSH host keys
  file {
    '/etc/ssh/ssh_host_dsa_key':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      source  => 'puppet:///private/ssh_host_dsa_key';
    '/etc/ssh/ssh_host_dsa_key.pub':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///private/ssh_host_dsa_key.pub';
    '/etc/ssh/ssh_host_rsa_key':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      source  => 'puppet:///private/ssh_host_rsa_key';
    '/etc/ssh/ssh_host_rsa_key.pub':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => 'puppet:///private/ssh_host_rsa_key.pub';
  }

  # apache must subscribe to all conf files
  service { 'apache2': }

  file { '/etc/apache2/sites-available/01-ssh.conf':
    ensure    => file,
    source    => 'puppet:///modules/tsunami/apache/sites/ssh.conf',
    notify    => Service['apache2'],
    require   => [ Package['apache2'] ],
  }

  file { '/etc/apache2/sites-available/02-ssl.conf':
    ensure    => file,
    source    => 'puppet:///modules/tsunami/apache/sites/ssl.conf',
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
    require     => [ File['/etc/ssl/certs/tsunami.ocf.berkeley.edu.crt'], File['/etc/ssl/private/tsunami.ocf.berkeley.edu.key'], Package['apache2'] ],
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

  # Provide SSL certificate and key
  file {
    '/etc/ssl/certs/tsunami.ocf.berkeley.edu.crt':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      source    => 'puppet:///private/tsunami.ocf.berkeley.edu.crt';
    '/etc/ssl/private/tsunami.ocf.berkeley.edu.key':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0600',
      source    => 'puppet:///private/tsunami.ocf.berkeley.edu.key';
    '/etc/ssl/certs/CA-BUNDLE.CRT':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      source    => 'puppet:///private/CA-BUNDLE.CRT';
  }

}
