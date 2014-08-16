class maelstrom {
  class { 'maelstrom::percona-apt':
    stage => first;
  }

  # install mysql and set root password
  package { 'percona-server-server-5.6':
    responsefile => '/opt/share/puppet/percona-server-server-5.6.preseed';
  }

  file { '/opt/share/puppet/percona-server-server-5.6.preseed':
    mode         => '0600',
    source       => 'puppet:///private/percona-server-server-5.6.preseed'
  }

  # provide mysql server and client config
  file {
    '/etc/mysql/my.cnf':
      source => 'puppet:///modules/maelstrom/my.cnf';
    '/root/.my.cnf':
      mode   => '0600',
      source => 'puppet:///private/root-my.cnf'
  }

  service { 'mysql':
    subscribe => File['/etc/mysql/my.cnf'],
    require   => Package['percona-server-server-5.6'];
  }

  package { 'percona-xtrabackup':; }
}
