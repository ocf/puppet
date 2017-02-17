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
  } ->
  class { 'ocf::packages::mysql_server':
    responsefile   => '/opt/share/puppet/mariadb-server-10.0.preseed',
    manage_service => false,
  } ->
  file { '/etc/mysql/conf.d/99ocf.cnf':
    source  => 'puppet:///modules/ocf_mysql/99ocf.cnf',
  } ~>
  service { 'mysql': }
}
