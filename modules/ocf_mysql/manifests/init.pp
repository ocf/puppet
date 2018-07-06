class ocf_mysql {
  file {
    # preseed root password
    '/opt/share/puppet/mariadb-server-10.0.preseed':
      mode      => '0600',
      source    => 'puppet:///private/mariadb-server-10.0.preseed',
      show_diff => false;

    '/root/.my.cnf':
      mode      => '0600',
      source    => 'puppet:///private/root-my.cnf',
      show_diff => false;
  }

  class { 'ocf::packages::mysql_server':
    responsefile   => '/opt/share/puppet/mariadb-server-10.0.preseed',
    manage_service => false,
    require        => File['/opt/share/puppet/mariadb-server-10.0.preseed'],
  }

  file { '/etc/mysql/mariadb.conf.d/99-ocf.cnf':
    source  => 'puppet:///modules/ocf_mysql/99-ocf.cnf',
    require => Class['ocf::packages::mysql_server'],
    notify  => Service['mysql'],
  }

  service { 'mysql': }

  # allow mysql (3306 udp/tcp)
  ocf::firewall::firewall46 {
    '101 allow mysql':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 3306,
        action => 'accept',
      };
  }
}
