class ocf::packages::cups {

  # install cups
  package { [ 'cups', 'cups-bsd' ]:
    install_options => ['--no-install-recommends']
  }

  # CVE-2024-47076, CVE-2024-47175, CVE-2024-47176, CVE-2024-47177
  package { [ 'cups-browsed' ]:
    ensure => 'absent'
  }

  file {
    # set print server destination
    '/etc/cups/client.conf':
      content => "ServerName printhost.ocf.berkeley.edu\nEncryption Always\n",
      require => Package[ 'cups', 'cups-bsd' ];
    # set default printer OCF-BW
    '/etc/cups/lpoptions':
      content => 'Default OCF-BW',
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
