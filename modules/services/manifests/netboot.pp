class services::netboot {

  # set up tftp for network booting
  package { 'tftpd-hpa': }
  file {
    '/opt/tftp':
      ensure  => directory;
    '/etc/default/tftpd-hpa':
      source  => 'puppet:///modules/services/netboot/tftpd-hpa',
      require => [ Package['tftpd-hpa'], File['/opt/tftp'] ]
  }
  service { 'tftpd-hpa':
    subscribe => File[ '/opt/tftp', '/etc/default/tftpd-hpa' ],
    require   => Package['tftpd-hpa']
  }

  # set up netboot image
  package { 'pax': }
  file {
    '/usr/local/sbin/ocf-netboot':
      mode    => '0755',
      source  => 'puppet:///modules/services/netboot/ocf-netboot',
      require => Package['pax'];
  }

  cron { "ocf-netboot":
    command => "/usr/local/sbin/ocf-netboot > /dev/null",
    user    => root,
    special => "weekly";
  }
}
