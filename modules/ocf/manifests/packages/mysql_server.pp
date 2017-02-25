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
      ensure   => stopped,

      # Can't disable services on stretch and default provider.
      # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=854680 rt#5940
      provider => systemd,

      enable   => false,
      require  => Package['mariadb-server'],
    }
  }

  # We make mysqladmin non-executable on servers which don't run a mysql
  # server in order to avoid a logrotate bug (rt#5981).
  $mysqladmin_mode = $manage_service ? {
    true  => '0644',
    false => '0755',
  }

  file { '/usr/bin/mysqladmin':
    mode => $mysqladmin_mode,
  }
}
