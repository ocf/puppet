class ocf_mysql {

  include ocf::ssl::default;

  user { 'mysql':
    groups => ['ssl-cert'];
  }

  file {
    '/root/.my.cnf':
      mode      => '0600',
      source    => 'puppet:///private/root-my.cnf',
      show_diff => false;
  }

  class { 'ocf::packages::mysql_server':
    manage_service => false,
  }

  file { '/etc/mysql/mariadb.conf.d/99-ocf.cnf':
    content => template('ocf_mysql/99-ocf.cnf'),
    require => Class['ocf::packages::mysql_server'],
    notify  => Service['mariadb'],
  }

  service { 'mariadb':
    subscribe => Class['ocf::ssl::default'];
  }

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
