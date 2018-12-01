class ocf::networking(
    $bridge     = false,
    $bond       = false,

    $ipaddress  = $::ipHostNumber,  # lint:ignore:variable_is_lowercase
    $netmask    = '255.255.255.0',
    $gateway    = '169.229.226.1',

    $ipaddress6 = regsubst($::ipHostNumber, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$', '2607:f140:8801::1:\4'),  # lint:ignore:variable_is_lowercase
    $netmask6   = '64',
    $gateway6   = '2607:f140:8801::1',

    $domain      = 'ocf.berkeley.edu',
    $nameservers = ['2607:f140:8801::1:22', '169.229.226.22', '8.8.8.8'],
) {

  if size($nameservers) > 3 {
    fail("Can't have more than 3 nameservers")
  }

  $fqdn = $::clientcert
  $hostname = regsubst($::clientcert, '^([\w-]+)\..*$', '\1')
  $linked_ifaces_array = split($::ifaces_linked, ' ')
  $first_active_iface = $linked_ifaces_array[0]

  # packages
  if $bond {
    package { 'ifenslave': }
  }

  package { 'resolvconf':
    ensure => purged,
  }

  # $logical_primary_interface is the one we want to add the IP address to.
  # in the basic case, it's just the active physical interface (desktops, VMs)
  # it could also be a bridge interface or bond interface with one or more
  # physical interfaces slaved to it.

  if $bridge {
    $logical_primary_interface = 'br0'

    if $bond {
      $bridged_iface = 'bond0'
    } else {
      $bridged_iface = $first_active_iface
    }
  } elsif $bond {
    $logical_primary_interface = 'bond0'
  } else {
    $logical_primary_interface = $first_active_iface
  }

  if $::lsbdistid == 'Raspbian' {
    # The raspberry pi has wifi, so we use that for networking
    $logical_primary_interface = 'wlan0'
  }

  if $bridge {
    file { '/etc/network/interfaces.d/br0':
      content => template('ocf/networking/interface_bridge.erb');
    }
  }

  if $bond {
    file { '/etc/network/interfaces.d/bond0':
      content => template('ocf/networking/interface_bond.erb');
    }
  }

  unless ($bond or $bridge) {
    file { "/etc/network/interfaces.d/${logical_primary_interface}":
      content => template('ocf/networking/interface_normal.erb');
    }
  }

  # network configuration
  file {
    '/etc/network/interfaces':
      source => 'puppet:///modules/ocf/networking/interfaces';
    '/etc/hostname':
      content => "${hostname}\n";
    '/etc/hosts':
      content => template('ocf/networking/hosts.erb');
    '/etc/resolv.conf':
      content => template('ocf/networking/resolv.conf.erb'),
      require => Package['resolvconf'];
  }

  # Enable TCP BBR congestion control
  sysctl {
    'net.core.default_qdisc':
      value => 'fq';
    'net.ipv4.tcp_congestion_control':
      value => 'bbr';

  }

  # disable IPv6 - SLAAC doesn't work for us yet
  # https://moffle.fuqu.jp/ocf/%23rebuild/20181024#L123
  sysctl { 'net.ipv6.conf.all.autoconf':
    value => '0';
  }

  # Make sure these are absent so predictable network iface names get used
  file {
    [
      '/etc/udev/rules.d/70-persistent-net.rules',
      '/etc/udev/rules.d/75-persistent-net-generator.rules',
      '/etc/systemd/network/50-virtio-kernel-names.link',
      '/etc/systemd/network/99-default.link',
    ]:
      ensure => absent;
  }

  # firewall configuration
  if $bridge {
    # Docker 1.13+ sets the iptables policy for the FORWARD chain to DROP.
    # (See https://github.com/docker/docker/pull/28257). As a side effect,
    # that prevents VMs from talking to anyone other than the host over
    # IPv4.
    # To fix this, add explicit rules allowing forwarding on the bridge
    # interface used by VMs.

    # On hypervisors the ethernet interface and VM TAP interfaces are all
    # connected to $iface. Any packet traveling between VMs, or between a
    # VM and the internet, will have an input interface and output interface
    # of $iface. Any packet which doesn't have this property should not be
    # forwarded (unless allowed for by a different iptables rule).
    firewall_multi { '100 allow traffic to/from VMs':
      chain    => 'FORWARD',
      proto    => 'all',
      iniface  => $bridged_iface,
      outiface => $bridged_iface,
      action   => 'accept',
    }
  }
}
