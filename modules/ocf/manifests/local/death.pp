class ocf::local::death {
  package {
    'autofs5-ldap':;
    'build-essential':; # for compiling mod_suexec and mod_userdir for apache
    'webserver':
        name => [ 'apache2', 'php5', 'libapache-mod-security', 'libapache2-mod-suphp', 'python-django', 'python-ldap', 'python-mysqldb', 'python-flup', 'python-cracklib' ]
  }
}
