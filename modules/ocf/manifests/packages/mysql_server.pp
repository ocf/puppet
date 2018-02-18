# Install the MySQL server package.
# In most cases, we only use it to run tests or something, so we just disable
# it. The actual MySQL server turns off manage_service.
class ocf::packages::mysql_server(
    $responsefile = undef,
    $manage_service = true,
) {
  package { 'mariadb-server':
    responsefile => $responsefile,
  }

  if $manage_service {
    service { 'mysql':
      ensure  => stopped,
      enable  => false,
      require => Package['mariadb-server'],
    }
  }

  # We make mysqladmin non-executable on servers which don't run a mysql
  # server in order to avoid a logrotate bug (rt#5981).
  $mysqladmin_mode = $manage_service ? {
    true  => '0644',
    false => '0755',
  }

  # TODO: Remove once mysqladmin is made executable on all hosts again
  # (rt#5981, fixed in mariadb-server 10.1.22-1, but some hosts are still on
  # jessie so they haven't been updated yet).
  file { '/usr/bin/mysqladmin':
    mode => $mysqladmin_mode,
  }
}
