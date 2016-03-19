class ocf_mysql {
  file {
    # preseed root password
    '/opt/share/puppet/mariadb-server-10.0.preseed':
      mode      => '0600',
      source    => 'puppet:///private/mariadb-server-10.0.preseed',
      show_diff => false;

    '/root/.my.cnf':
      mode   => '0600',
      source => 'puppet:///private/root-my.cnf';
  }

  package { 'mariadb-server':
    responsefile => '/opt/share/puppet/mariadb-server-10.0.preseed',
    require      => File['/opt/share/puppet/mariadb-server-10.0.preseed'],
  }

  service { 'mysql':
    require => Package['mariadb-server'];
  }

  augeas { '/etc/mysql/my.cnf':
    lens    => 'MySQL.lns',
    incl    => '/etc/mysql/my.cnf',
    changes => [
      "set target[.='mysqld']/bind-address 0.0.0.0",

      # https://mariadb.com/kb/en/mariadb/optimizing-key_buffer_size/
      # XXX: the config variable is actually "key_buffer_size", but the Debian
      # config file is wrong and uses deprecated "key_buffer".
      "rm target[.='mysqld']/key_buffer",
      "set target[.='mysqld']/key_buffer_size 2G",

      "set target[.='mysqld']/max_connections 1000",
      "set target[.='mysqld']/max_user_connections 50",

      # https://dev.mysql.com/doc/refman/5.5/en/table-cache.html
      # table_open_cache should be at least max_connections * N
      # (where N = number of tables per join)
      "set target[.='mysqld']/table_open_cache 4000",

      # http://haydenjames.io/mysql-query-cache-size-performance/
      "set target[.='mysqld']/query_cache_size 32M",

      # https://mariadb.com/kb/en/mariadb/xtradbinnodb-server-system-variables/
      # https://dev.mysql.com/doc/refman/5.6/en/innodb-multiple-buffer-pools.html
      "set target[.='mysqld']/innodb_file_per_table 1",
      "set target[.='mysqld']/innodb_buffer_pool_size 8G",
      "set target[.='mysqld']/innodb_buffer_pool_instances 8",
      "set target[.='mysqld']/innodb_flush_log_at_trx_commit 1",

      # http://dev.mysql.com/doc/refman/5.6/en/innodb-parameters.html#sysvar_innodb_log_buffer_size
      "set target[.='mysqld']/innodb_log_buffer_size 256M",
      "set target[.='mysqld']/innodb_log_file_size 1G",
    ],
    require => Package['mariadb-server'],
    notify  => Service['mysql'],
  }
}
