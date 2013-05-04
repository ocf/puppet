class common::cups {

  # install cups
  package { [ 'cups', 'cups-bsd' ]: }

  file {
    # set print server destination
    '/etc/cups/client.conf':
      content => "ServerName printhost\nEncryption Always",
      require => Package[ 'cups', 'cups-bsd' ];
    # set default printer double
    '/etc/cups/lpoptions':
      content => 'Default double',
      require => Package[ 'cups', 'cups-bsd' ];
    # set default paper size
    '/etc/papersize':
      content => 'letter'
  }

  service { 'cups':
    subscribe => File['/etc/cups/client.conf', '/etc/cups/lpoptions'],
    require   => Package[ 'cups', 'cups-bsd' ];
  }

}
