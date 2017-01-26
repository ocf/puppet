class ocf_dhcp::netboot {
  # Set up tftp for network booting
  package { 'tftpd-hpa': }

  file {
    '/opt/tftp':
      ensure  => directory;

    '/etc/default/tftpd-hpa':
      source  => 'puppet:///modules/ocf_dhcp/netboot/tftpd-hpa',
      require => [Package['tftpd-hpa'], File['/opt/tftp']];
  }

  service { 'tftpd-hpa':
    subscribe => File[ '/opt/tftp', '/etc/default/tftpd-hpa' ],
    require   => Package['tftpd-hpa'],
  }

  # Set up netboot image
  package { ['pax', 'p7zip-full']: }

  file {
    '/usr/local/sbin/ocf-netboot':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_dhcp/netboot/ocf-netboot',
      require => [Package['pax'], Service['tftpd-hpa']];
  }

  cron { 'ocf-netboot':
    command => '/usr/local/sbin/ocf-netboot > /dev/null',
    user    => root,
    special => 'weekly';
  }
}
