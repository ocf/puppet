class ocf::packages::cups {

  # install cups
  package { [ 'cups', 'cups-bsd', 'cups-tea4cups' ]: }

  file {
    # set print server destination
    '/etc/cups/client.conf':
      content => "ServerName localhost\nEncryption Always\n",
      require => Package[ 'cups', 'cups-bsd' ];
    # set default printer double
    '/etc/cups/lpoptions':
      content => 'Default double',
      require => Package[ 'cups', 'cups-bsd' ];
    # set default paper size
    '/etc/papersize':
      content => 'letter';
    # set printer configurations
    '/etc/cups/printers.conf':
      source  => 'puppet:///modules/ocf/packages/cups/printers.conf',
      group   => 'lp',
      require => Package['cups', 'cups-bsd'],
      notify  => Service['cups'];
    '/etc/cups/ppd/single.ppd':
      # content => epp('ocf/cups/raster.ppd.epp', { 'double' => false }),
      # group   => 'lp',
      ensure  => absent,
      require => Package['cups', 'cups-bsd'],
      notify  => Service['cups'];
    '/etc/cups/ppd/double.ppd':
      # content => epp('ocf/cups/raster.ppd.epp', { 'double' => true }),
      # group   => 'lp',
      ensure  => absent,
      require => Package['cups', 'cups-bsd'],
      notify  => Service['cups'];
    # set rasterizing filter
    '/usr/lib/cups/filter/raster-filter':
      source => 'puppet:///modules/ocf/packages/cups/raster-filter',
      mode   => '0755';
    # set tea4cups configurations
    '/etc/cups/tea4cups.conf':
      source  => 'puppet:///modules/ocf/packages/cups/tea4cups.conf',
      require => Package['cups-tea4cups'];
    # set convert_failure script for raster-filter
    '/usr/local/bin/convert_failure':
      source => 'puppet:///modules/ocf/packages/cups/convert_failure',
      mode   => '0755';
  }

  service { 'cups':
    subscribe => File['/etc/cups/client.conf', '/etc/cups/lpoptions'],
    require   => Package[ 'cups', 'cups-bsd' ];
  }

}
