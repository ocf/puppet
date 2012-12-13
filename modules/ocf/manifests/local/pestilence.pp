class ocf::local::pestilence {

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file { '/etc/dhcp/dhcpd.conf':
    source   => 'puppet:///modules/ocf/local/pestilence/dhcpd.conf',
    require  => Package['isc-dhcp-server'],
    notify   => Service['isc-dhcp-server']
  }
  service { 'isc-dhcp-server':
    subscribe => File['/etc/dhcp/dhcpd.conf']
  }

  # send magic packet to wakeup desktops at lab opening time
  package { 'wakeonlan': }
  file {
    '/usr/local/bin/ocf-wakeup':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/pestilence/wakeup/script',
      require => Package['wakeonlan'];
    '/etc/cron.d/ocf-wakeup':
      source  => 'puppet:///modules/ocf/local/pestilence/wakeup/cron',
      require => File['/usr/local/bin/ocf-wakeup']
  }

}
