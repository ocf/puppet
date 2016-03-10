class ocf_ssh::makeservices {
  # enable regular users to run makemysql.py as mysql
  file { '/etc/sudoers.d/makeservices':
    content => "ALL ALL=(mysql) NOPASSWD: /opt/share/utils/makeservices/makemysql-real\n";
  }

  file {
    '/opt/share/makeservices':
      ensure => directory,
      mode   => '0500',
      owner  => 'mysql';
    '/opt/share/makeservices/makemysql.conf':
      source => 'puppet:///private/makeservices/makemysql.conf';
  }
}
