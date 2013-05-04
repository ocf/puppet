class common::mysql {

  package { 'mysql-client': }

  # MySQL client config
  file { '/etc/mysql/my.cnf':
    content => "[client]\nhost=mysql\npassword",
    require => Package['mysql-client'],
  }

}
