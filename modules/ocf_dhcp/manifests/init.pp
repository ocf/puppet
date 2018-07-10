class ocf_dhcp {
  require ocf::networking
  include ocf_dhcp::netboot

  # setup dhcp server
  package { 'isc-dhcp-server': }
  file {
    '/etc/dhcp/dhcpd.conf':
      source  => 'puppet:///modules/ocf_dhcp/dhcpd.conf',
      require => Package['isc-dhcp-server'],
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

    'gen-desktop-leases':
      command => '/usr/local/sbin/gen-desktop-leases',
      minute  => '*/15',
      require => [File['/usr/local/sbin/gen-desktop-leases'], Package['python3-ocflib']];
  }

  # Allow DHCP server traffic
  firewall_multi { '101 allow dhcp server':
    chain  => 'PUPPET-INPUT',
    proto  => 'udp',
    dport  => 67,
    action => 'accept',
  }
}
