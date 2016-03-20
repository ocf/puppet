class ocf::packages::mysql {
  package {
    'mysql-client':
      ensure => purged;

    'mariadb-client':
      require => Package['mysql-client'];
  }

  # don't install mysql client configs if this is also a mysql server
  if !tagged('ocf_mysql') {
    # MySQL client config
    file { '/etc/mysql/my.cnf':
      content => "[client]\nhost=mysql\npassword",
      require => Package['mysql-client'];
    }
  }
}
