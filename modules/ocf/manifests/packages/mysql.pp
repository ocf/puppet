class ocf::packages::mysql {
  package { 'mysql-client':; }

  # don't install mysql client configs if this is also a mysql server
  # (this happens on servers with both ocf_www and ocf_mysql)
  if !tagged('ocf_mysql') {
    # MySQL client config
    file { '/etc/mysql/my.cnf':
      content => "[client]\nhost=mysql\npassword",
      require => Package['mysql-client'];
    }
  }
}
