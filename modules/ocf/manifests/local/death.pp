class ocf::local::death {
  include ocf::common::mount
  package {
    [ 'apache2', 'php5', 'php5-mysql', 'libapache-mod-security', 'libapache2-mod-suphp', 'python-django', 'python-ldap', 'python-mysqldb', 'python-flup', 'python-cracklib', 'apache2-threaded-dev', 'libapache2-mod-fcgid' ]:
      ensure  => installed;
    'nfs-kernel-server':
      ensure  => installed;
  }

  file { '/etc/apache2/httpd.conf':
    ensure    => file,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    source    => 'puppet:///modules/ocf/local/death/apache/httpd.conf',
    require   => [ Package['apache2'] ],
    notify      => Service['apache2'],
  }

  file { '/etc/apache2/sites-available':
    ensure    => directory,
    owner     => 'root',
    group     => 'root',
    mode      => '0644',
    recurse   => true,
    require   => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/21-account_tools.conf':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/sites/account_tools.conf',
  }

  file { '/etc/apache2/sites-available/22-staff_hours.conf':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/sites/staff_hours.conf',
  }

  file { '/etc/apache2/sites-available/02-ssl.conf':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/sites/ssl.conf',
  }

  file { '/etc/apache2/sites-available/03-userdir.conf':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/sites/userdir.conf',
  }

  file { '/etc/apache2/sites-available/01-www.conf':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/sites/www.conf',
  }

  file { '/etc/apache2/mods-available':
    ensure    => directory,
    require   => Package['apache2'],
  }

  file { '/etc/apache2/mods-available/mod_ocfdir.c':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/mods/mod_ocfdir.c',
  }

  file { '/usr/lib/apache2':
    ensure   => directory,
    require  => Package['apache2'],
  } 

  file { '/usr/lib/apache2/suexec':
    ensure    => file,
    source    => 'puppet:///modules/ocf/local/death/apache/mods/suexec',
    backup    => false, # it's a binary file
    mode      => '4755',
    owner     => 'root',
    group     => 'www-data',
    require   => Package['apache2'],
  }

  exec { '/usr/bin/apxs2 -i -c -a -n ocfdir /etc/apache2/mods-available/mod_ocfdir.c':
    require     => [ Package['apache2-threaded-dev'], File['/etc/apache2/mods-available/mod_ocfdir.c'] ],
    notify      => Service['apache2'],
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/ocfdir.load",
  }

  # enable apache modules
  exec { '/usr/sbin/a2enmod rewrite':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load",
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }
  exec { '/usr/sbin/a2enmod fcgid':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/fcgid.load",
    notify      => Service['apache2'],
    require     => [Package['apache2'], Package['libapache2-mod-fcgid']],
  }
  exec { '/usr/sbin/a2enmod include':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/include.load",
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }
  exec { '/usr/sbin/a2enmod suexec':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/suexec.load",
    notify      => Service['apache2'],
    require     => [Package['apache2'], File['/usr/lib/apache2/suexec']],
  }
  exec { '/usr/sbin/a2enmod suphp':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/suphp.load",
    notify      => Service['apache2'],
    require     => [Package['apache2'], Package['libapache2-mod-suphp']],
  }
  exec { '/usr/sbin/a2enmod ssl':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/ssl.load",
    notify      => Service['apache2'],
    require     => [ File['/etc/ssl/certs/secure.ocf.berkeley.edu.crt'], File['/etc/ssl/private/secure.ocf.berkeley.edu.key'], Package['apache2'] ],
  }
  exec { '/usr/sbin/a2enmod userdir':
    unless      => "/bin/readlink -e /etc/apache2/mods-enabled/userdir.load",
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }

  # disable default site
  exec { '/usr/sbin/a2dissite 000-default':
    onlyif      => "/bin/readlink -e /etc/apache2/sites-enabled/000-default",
    require     => Package['apache2'],
    notify      => Service['apache2'],
  }

  # disable the php5 module because it conflicts with suphp
  exec { '/usr/sbin/a2dismod php5':
    onlyif      => "/bin/readlink -e /etc/apache2/mods-enabled/php5.load",
    require     => Package['apache2', 'php5'],
    notify      => Service['apache2'],
  }

  # enable sites
  exec { '/usr/sbin/a2ensite 21-account_tools.conf':
    unless      => "/bin/readlink -e /etc/apache2/sites-enabled/21-account_tools.conf",
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], File['/etc/apache2/sites-available/21-account_tools.conf']],
  }
  exec { '/usr/sbin/a2ensite 02-ssl.conf':
    unless      => "/bin/readlink -e /etc/apache2/sites-enabled/02-ssl.conf",
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], File['/etc/apache2/sites-available/02-ssl.conf']],
  }
  exec { '/usr/sbin/a2ensite 22-staff_hours.conf':
    unless      => "/bin/readlink -e /etc/apache2/sites-enabled/22-staff_hours.conf",
    notify      => Service['apache2'],
    require     => File['/etc/apache2/sites-available/22-staff_hours.conf'],
  }
  exec { '/usr/sbin/a2ensite 03-userdir.conf':
    unless      => "/bin/readlink -e /etc/apache2/sites-enabled/03-userdir.conf",
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod userdir'], File['/etc/apache2/sites-available/03-userdir.conf']],
  }
  exec { '/usr/sbin/a2ensite 01-www.conf':
    unless      => "/bin/readlink -e /etc/apache2/sites-enabled/01-www.conf",
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], Exec['/usr/sbin/a2enmod include'], File['/etc/apache2/sites-available/01-www.conf']],
  }

  # suphp is separated from apache
  file {
    '/etc/suphp/suphp.conf':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      source    => 'puppet:///modules/ocf/local/death/apache/mods/suphp.config.ocf',
      require   => Package['libapache2-mod-suphp'],
  }

  # copy ssl files
  file {
    '/etc/ssl/certs/secure.ocf.berkeley.edu.crt':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0600',
      source    => 'puppet:///private/secure.ocf.berkeley.edu.crt';
    '/etc/ssl/private/secure.ocf.berkeley.edu.key':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      source    => 'puppet:///private/secure.ocf.berkeley.edu.key';
  }

  # apache must subscribe to all conf files
  service { 'apache2':
    ensure  => 'running',
    provider => 'debian',
  }

  # nfs export of apache logs
  file {
    '/etc/exports':
      ensure    => file,
      source    => 'puppet:///modules/ocf/local/death/exports',
      require   => Package['nfs-kernel-server', 'apache2'],
      notify    => Service['nfs-kernel-server'],
  }

  service { 'nfs-kernel-server':
    ensure => 'running',
  }
}
