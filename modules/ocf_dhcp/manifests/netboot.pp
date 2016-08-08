class ocf_dhcp::netboot {
  # set up tftp for network booting
  package { 'tftpd-hpa': }

  file {
    '/opt/tftp':
      ensure  => directory;
    '/etc/default/tftpd-hpa':
      source  => 'puppet:///modules/ocf_dhcp/netboot/tftpd-hpa',
      require => [ Package['tftpd-hpa'], File['/opt/tftp'] ]
  }

  service { 'tftpd-hpa':
    subscribe => File[ '/opt/tftp', '/etc/default/tftpd-hpa' ],
    require   => Package['tftpd-hpa']
  }

  # set up netboot image
  package { ['pax', 'p7zip-full']: }

  file {
    '/usr/local/sbin/ocf-netboot':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_dhcp/netboot/ocf-netboot',
      require => Package['pax'];

    # Unfortunately, there is no good way to get a finnix tarball via script.
    # The best way is:
    #   - boot finnix from ISO in a virtual machine
    #   - run `finnix-netboot-server`.
    #   - make sure to select "fat initrd" instead of the NFS option; this
    #     requires more memory but lets us avoid an NFS server during netboot
    #   - cd /srv/tfp && tar cfz finnix.tar.gz finnix
    #   - scp finnix.tar.gz puppet:/opt/puppet/shares/contrib/local/ocf_dhcp/
    # Note that the "fat" initrd requires ~0.75 GB of memory, so if you're
    # testing with a VM, be sure to give it sufficient RAM.
    '/var/lib/finnix.tar.gz':
      source => 'puppet:///contrib/local/ocf_dhcp/finnix.tar.gz',
      backup => false;
  }

  cron { 'ocf-netboot':
    command     => '/usr/local/sbin/ocf-netboot > /dev/null',
    user        => root,
    special     => 'weekly',
    require     => File['/var/lib/finnix.tar.gz'];
  }
}
