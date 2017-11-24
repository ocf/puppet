class ocf_dhcp {
  require ocf::networking
  include ocf_dhcp::netboot

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file {
    '/etc/dhcp/dhcpd.conf':
      source  => 'puppet:///modules/ocf_dhcp/dhcpd.conf',
      require => [Package['isc-dhcp-server'], Exec['gen-desktop-leases']],
      notify  => Service['isc-dhcp-server'];

    '/usr/local/sbin/gen-desktop-leases':
      source => 'puppet:///modules/ocf_dhcp/gen-desktop-leases',
      mode   => '0755';
  }

  augeas {
    '/etc/default/isc-dhcp-server':
      context => '/files/etc/default/isc-dhcp-server',
      changes => [
        'rm INTERFACESv4',
        'rm INTERFACESv6',
        "set INTERFACES '\"${ocf::networking::iface}\"'",
      ],
      require => Package['isc-dhcp-server'];
  }

  exec { 'gen-desktop-leases':
    command => '/usr/local/sbin/gen-desktop-leases > /etc/dhcp/desktop-leases.conf',
    creates => '/etc/dhcp/desktop-leases.conf',
    require => [File['/usr/local/sbin/gen-desktop-leases'], Package['python3-ocflib']],
    notify  => Service['isc-dhcp-server'];
  }

  service { 'isc-dhcp-server':
    subscribe => [File['/etc/dhcp/dhcpd.conf'], Augeas['/etc/default/isc-dhcp-server']],
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
  }

  # Allow BOOTP (IPv4 only)
  firewall_multi { '101 allow bootps':
    chain  => 'PUPPET-INPUT',
    proto  => 'udp',
    dport  => 67,
    action => 'accept',
  }

  # Allow DHCP Server (IPv6 only)
  firewall_multi { '101 allow dhcpv6-server':
    provider => 'ip6tables',
    chain    => 'PUPPET-INPUT',
    proto    => 'udp',
    dport    => 547,
    action   => 'accept',
  }
}
