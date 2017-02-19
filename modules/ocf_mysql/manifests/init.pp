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

  class { 'ocf::packages::mysql_server':
    responsefile   => '/opt/share/puppet/mariadb-server-10.0.preseed',
    manage_service => false,
    require        => File['/opt/share/puppet/mariadb-server-10.0.preseed'],
  }

  # Listen on all interfaces and on both IPv4/IPv6
  augeas { '/etc/mysql/mariadb.conf.d/50-server.cnf':
    lens    => 'MySQL.lns',
    incl    => '/etc/mysql/mariadb.conf.d/50-server.cnf',
    changes => [
      "set target[.='mysqld']/bind-address ::",
    ],
    require => Class['ocf::packages::mysql_server'],
    notify  => Service['mysql'],
  }

  file { '/etc/mysql/conf.d/99ocf.cnf':
    source  => 'puppet:///modules/ocf_mysql/99ocf.cnf',
    require => Class['ocf::packages::mysql_server'],
    notify  => Service['mysql'],
  }

  service { 'mysql': }
}
