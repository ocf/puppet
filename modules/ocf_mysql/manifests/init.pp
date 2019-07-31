class ocf_mysql {
  require ocf::ssl::default;

  class { 'ocf::packages::mysql_server':
    manage_service => false,
  } ->
  user { 'mysql':
    groups => ['ssl-cert'];
  } ->
  file {
    '/etc/mysql/mariadb.conf.d/99-ocf.cnf':
      content => template('ocf_mysql/99-ocf.cnf');

    '/root/.my.cnf':
      mode      => '0600',
      content   => template('ocf_mysql/root-my.cnf.erb'),
      show_diff => false;
  } ~>
  service { 'mariadb': }

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
