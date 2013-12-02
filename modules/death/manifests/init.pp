class death {
  package {
    [ 'apache2', 'libapache-mod-security', 'apache2-threaded-dev', 'libapache2-mod-fcgid']:
      before => Package['libapache2-mod-php5'],
    ;
    # php
    ['php5', 'php5-mysql', 'libapache2-mod-suphp', 'php5-gd', 'php5-curl', 'php5-mcrypt']:
      before => Package['libapache2-mod-php5'],
    ;
    # mod-php interferes with suphp and fcgid but is pulled in as recommended dependency
    'libapache2-mod-php5':
      ensure => purged,
    ;
    # python and django
    ['python-django', 'python-mysqldb', 'python-flup', 'python-flask', 'python-sqlalchemy']:
    ;
    # perl
    ['libdbi-perl']:
    ;
    # ruby and rails
    ['rails', 'libfcgi-ruby1.8', 'libmysql-ruby']:
    ;
    ['nfs-kernel-server']:
    ;
    # for staff_hours.cgi (perl)
    'libhtml-parser-perl':
    ;
    # for account_tools
    ['python-ldap', 'python-pexpect', 'python-paramiko']:
    ;
  }

  file { '/etc/apache2/conf.d':
    ensure  => directory,
    recurse => true,
    source  => 'puppet:///modules/death/apache/conf.d',
    require => Package['apache2'],
    notify  => Service['apache2'],
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
    source    => 'puppet:///modules/death/apache/sites/account_tools.conf',
    notify    => Service['apache2'],
    require   => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/02-ssl.conf':
    ensure    => file,
    source    => 'puppet:///modules/death/apache/sites/ssl.conf',
    notify    => Service['apache2'],
    require   => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/03-userdir.conf':
    ensure    => file,
    source    => 'puppet:///modules/death/apache/sites/userdir.conf',
    notify    => Service['apache2'],
    require   => Package['apache2'],
  }

  file { '/etc/apache2/sites-available/01-www.conf':
    ensure    => file,
    source    => 'puppet:///modules/death/apache/sites/www.conf',
    notify    => Service['apache2'],
    require   => Package['apache2'],
  }

  file { '/etc/apache2/sites-common.conf':
    source    => 'puppet:///modules/death/apache/sites-common.conf',
    notify    => Service['apache2'],
    require   => Package['apache2'],
  }

  file { '/etc/apache2/mods-available':
    ensure    => directory,
    require   => Package['apache2'],
  }

  file { '/etc/apache2/mods-available/mod_ocfdir.c':
    ensure    => file,
    source    => 'puppet:///modules/death/apache/mods/mod_ocfdir.c',
  }

  file { '/usr/lib/apache2':
    ensure   => directory,
    require  => Package['apache2'],
  }

  file { '/usr/lib/apache2/suexec':
    ensure    => file,
    source    => 'puppet:///contrib/local/death/suexec',
    backup    => false, # it's a binary file
    mode      => '4750',
    owner     => 'root',
    group     => 'www-data',
    require   => Package['apache2'],
  }

  exec { '/usr/bin/apxs2 -i -c -a -n ocfdir /etc/apache2/mods-available/mod_ocfdir.c':
    require     => [ Package['apache2-threaded-dev'], File['/etc/apache2/mods-available/mod_ocfdir.c'] ],
    notify      => Service['apache2'],
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/ocfdir.load',
  }

  # enable apache modules
  exec { '/usr/sbin/a2enmod rewrite':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/rewrite.load',
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }
  exec { '/usr/sbin/a2enmod fcgid':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/fcgid.load',
    notify      => Service['apache2'],
    require     => [Package['apache2'], Package['libapache2-mod-fcgid']],
  }
  exec { '/usr/sbin/a2enmod headers':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/headers.load',
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }
  exec { '/usr/sbin/a2enmod include':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/include.load',
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }
  exec { '/usr/sbin/a2enmod suexec':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/suexec.load',
    notify      => Service['apache2'],
    require     => [Package['apache2'], File['/usr/lib/apache2/suexec']],
  }
  exec { '/usr/sbin/a2enmod suphp':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/suphp.load',
    notify      => Service['apache2'],
    require     => [Package['apache2'], Package['libapache2-mod-suphp']],
  }
  exec { '/usr/sbin/a2enmod ssl':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/ssl.load',
    notify      => Service['apache2'],
    require     => [ File['/etc/ssl/certs/secure.ocf.berkeley.edu.crt'], File['/etc/ssl/private/secure.ocf.berkeley.edu.key'], Package['apache2'] ],
  }
  exec { '/usr/sbin/a2enmod userdir':
    unless      => '/bin/readlink -e /etc/apache2/mods-enabled/userdir.load',
    notify      => Service['apache2'],
    require     => Package['apache2'],
  }

  # disable default site
  exec { '/usr/sbin/a2dissite 000-default':
    onlyif      => '/bin/readlink -e /etc/apache2/sites-enabled/000-default',
    require     => Package['apache2'],
    notify      => Service['apache2'],
  }

  # disable the php5 module because it conflicts with suphp
  exec { '/usr/sbin/a2dismod php5':
    onlyif      => '/bin/readlink -e /etc/apache2/mods-enabled/php5.load',
    require     => Package['apache2', 'php5'],
    notify      => Service['apache2'],
  }

  # enable sites
  exec { '/usr/sbin/a2ensite 21-account_tools.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/21-account_tools.conf',
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], File['/etc/apache2/sites-available/21-account_tools.conf']],
  }
  exec { '/usr/sbin/a2ensite 02-ssl.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/02-ssl.conf',
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], File['/etc/apache2/sites-available/02-ssl.conf']],
  }
  exec { '/usr/sbin/a2ensite 03-userdir.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/03-userdir.conf',
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod userdir'], File['/etc/apache2/sites-available/03-userdir.conf']],
  }
  exec { '/usr/sbin/a2ensite 01-www.conf':
    unless      => '/bin/readlink -e /etc/apache2/sites-enabled/01-www.conf',
    notify      => Service['apache2'],
    require     => [Exec['/usr/sbin/a2enmod rewrite'], Exec['/usr/sbin/a2enmod include'], File['/etc/apache2/sites-available/01-www.conf']],
  }

  # dpkg-divert
  exec { '/usr/bin/dpkg-divert --divert /usr/lib/apache2/suexec.dist --rename /usr/lib/apache2/suexec':
    unless      => '/usr/bin/dpkg-divert --list | grep suexec',
    require     => File['/usr/lib/apache2/suexec'],
  }

  # suphp is separated from apache
  file {
    '/etc/suphp/suphp.conf':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      source    => 'puppet:///modules/death/apache/mods/suphp.config.ocf',
      require   => Package['libapache2-mod-suphp'],
  }

  #php ini file
  file {
    '/etc/php5/cgi/php.ini':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      mode      => '0644',
      source    => 'puppet:///modules/death/apache/mods/php.ini',
      require   => Package['php5'],
  }

  # copy ssl files
  file {
    '/etc/ssl/certs/secure.ocf.berkeley.edu.crt':
      ensure    => file,
      owner     => 'root',
      group     => 'ssl-cert',
      mode      => '0640',
      source    => 'puppet:///private/secure.ocf.berkeley.edu.crt';
    '/etc/ssl/private/secure.ocf.berkeley.edu.key':
      ensure    => file,
      owner     => 'root',
      group     => 'ssl-cert',
      mode      => '0640',
      source    => 'puppet:///private/secure.ocf.berkeley.edu.key';
    '/etc/ssl/certs/CA-BUNDLE.CRT':
      ensure    => file,
      owner     => 'root',
      group     => 'root',
      source    => 'puppet:///private/CA-BUNDLE.CRT';
  }

  # apache must subscribe to all conf files
  service { 'apache2': }

  # config files for account-tools
  file {
    '/var/www/account_tools/config':
      ensure   => directory,
      mode     => '0750',
      owner    => 'account-tools',
      group    => 'account-tools';
    '/var/www/account_tools/config/cmds_host_keys':
      ensure   => file,
      mode     => '0440',
      owner    => 'account-tools',
      group    => 'account-tools',
      source   => 'puppet:///private/account_tools/host_keys';
    '/var/www/account_tools/config/chpass.keytab':
      ensure   => file,
      mode     => '0400',
      owner    => 'account-tools',
      group    => 'account-tools',
      source   => 'puppet:///private/account_tools/chpass.keytab';
  }

  # nfs export of apache logs
  file {
    '/etc/exports':
      ensure    => file,
      source    => 'puppet:///modules/death/exports',
      require   => Package['nfs-kernel-server', 'apache2'],
      notify    => Service['nfs-kernel-server'],
  }

  # make sure logratate changes the permissions so that it is viewable when exported
  file {
    '/etc/logrotate.d/apache2':
      ensure    => file,
      source    => 'puppet:///modules/death/logrotate/apache2',
  }

  service { 'nfs-kernel-server': }
}
