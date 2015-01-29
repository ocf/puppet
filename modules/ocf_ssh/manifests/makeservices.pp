class ocf_ssh::makeservices {
  # enable regular users to run makemysql.py as mysql
  file { '/etc/sudoers.d/makeservices':
    content => "ALL ALL=(mysql) NOPASSWD: /opt/share/utils/makeservices/makemysql-real\n";
  }
}
