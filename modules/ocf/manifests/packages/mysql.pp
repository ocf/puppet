class ocf::packages::mysql {
  package {
    'mysql-client':
      ensure => purged;

    'mariadb-client':
      require => Package['mysql-client'];
  }

  # only install mysql client configs if this is not a mysql server
  unless tagged('ocf_mysql') {
    # MySQL client config
    file { '/etc/mysql/my.cnf':
      content => "[client]\nhost=mysql\npassword",
      require => Package['mysql-client'];
    }
  }
}
