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
    require => Package['mariadb-server'],
  }

  file { '/etc/mysql/conf.d/99ocf.cnf':
    source  => 'puppet:///modules/ocf_mysql/99ocf.cnf',
    require => Package['mariadb-server'],
    notify  => Service['mysql'],
  }
}
