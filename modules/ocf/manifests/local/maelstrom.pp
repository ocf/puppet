class ocf::local::maelstrom {

  # install mysql and set root password
  package { 'mysql-server-5.1':
    responsefile => '/opt/share/puppet/mysql-server-5.1.preseed'
  }
  file { '/opt/share/puppet/mysql-server-5.1.preseed':
    mode         => '0600',
    source       => 'puppet:///private/mysql-server-5.1.preseed'
  }

  # provide mysql server and client config
  file {
    '/etc/mysql/my.cnf':
      source => 'puppet:///modules/ocf/local/maelstrom/my.cnf';
    '/root/.my.cnf':
      mode   => '0600',
      source => 'puppet:///private/root-my.cnf'
  }

  service { 'mysql':
    subscribe => File['/etc/mysql/my.cnf'],
    require   => Package['mysql-server-5.1']
  }

}
