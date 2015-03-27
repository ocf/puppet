class ocf::networking::hostname {

  # set FQDN and hostname from SSL client certificate
  $fqdn = $::clientcert
  $hostname = regsubst($::clientcert, '^(\w+)\..*$', '\1')

  # provide hostname and FQDN
  file {
    '/etc/hostname':
      content => "${hostname}\n",
    ;
    '/etc/hosts':
      content => "127.0.0.1 localhost\n${::ipaddress} ${fqdn} ${hostname}\n",
    ;
  }

}
