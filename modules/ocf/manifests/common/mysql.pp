class ocf::common::mysql {

  # MySQL client config
  file { '/etc/mysql/my.cnf':
    content => "[client]\nhost=mysql\npassword",
  }

}
