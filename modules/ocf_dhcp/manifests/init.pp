class ocf_dhcp {
  include ocf_dhcp::netboot

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file {
    '/etc/dhcp/dhcpd.conf':
      source   => 'puppet:///modules/ocf_dhcp/dhcpd.conf',
      require  => [Package['isc-dhcp-server'], Exec['gen-desktop-leases']],
      notify   => Service['isc-dhcp-server'];

    '/usr/local/sbin/gen-desktop-leases':
      source => 'puppet:///modules/ocf_dhcp/gen-desktop-leases',
      mode   => '0755';
  }
  exec { 'gen-desktop-leases':
    command    => '/usr/local/sbin/gen-desktop-leases > /etc/dhcp/desktop-leases.conf',
    creates    => '/etc/dhcp/desktop-leases.conf',
    require    => File['/usr/local/sbin/gen-desktop-leases'],
    notify     => Service['isc-dhcp-server'];
  }
  service { 'isc-dhcp-server':
    subscribe => File['/etc/dhcp/dhcpd.conf']
  }

  # send magic packet to wakeup desktops at lab opening time
  package { 'wakeonlan': }
  file {
    '/usr/local/bin/lab-wakeup':
      ensure  => link,
      links   => manage,
      target  => '/opt/share/utils/staff/lab/lab-wakeup',
      require => [Vcsrepo['/opt/share/utils'], Package['wakeonlan']];
  }

  cron {
    'lab-wakeup':
      command => '/usr/local/bin/lab-wakeup -q',
      minute  => '*/15',
      require => File['/usr/local/bin/lab-wakeup'];

    # TODO: remove in a few weeks
    ['lab-wakeup-weekdays', 'lab-wakeup-saturday', 'lab-wakeup-sunday']:
      ensure  => absent;
  }
}
