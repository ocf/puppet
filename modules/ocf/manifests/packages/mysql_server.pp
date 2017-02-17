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
}
