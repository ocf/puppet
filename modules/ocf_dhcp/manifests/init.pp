class ocf_dhcp {
  include netboot

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
      require => Package['wakeonlan'];
  }

  cron {
    'lab-wakeup-weekdays':
      command => '/usr/local/bin/lab-wakeup > /dev/null',
      hour    => 9,
      minute  => 0,
      weekday => '1-5',
      require => File['/usr/local/bin/lab-wakeup'];
    'lab-wakeup-saturday':
      command => '/usr/local/bin/lab-wakeup > /dev/null',
      hour    => 11,
      minute  => 0,
      weekday => 6,
      require => File['/usr/local/bin/lab-wakeup'];
    'lab-wakeup-sunday':
      command => '/usr/local/bin/lab-wakeup > /dev/null',
      hour    => 12,
      minute  => 0,
      weekday => 0,
      require => File['/usr/local/bin/lab-wakeup'];
  }
}
