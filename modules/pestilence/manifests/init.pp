class pestilence {

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file {
    '/etc/dhcp/dhcpd.conf':
      source   => 'puppet:///modules/pestilence/dhcpd.conf',
      require  => [Package['isc-dhcp-server'], Exec['gen-desktop-leases']],
      notify   => Service['isc-dhcp-server'];
    '/usr/local/sbin/gen-desktop-leases':
      source   => 'puppet:///modules/pestilence/gen-desktop-leases',
      mode     => 755;
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
    '/usr/local/bin/ocf-wakeup':
      mode    => '0755',
      source  => 'puppet:///modules/pestilence/wakeup/script',
      require => Package['wakeonlan'];
    '/etc/cron.d/ocf-wakeup':
      source  => 'puppet:///modules/pestilence/wakeup/cron',
      require => File['/usr/local/bin/ocf-wakeup']
  }

}
