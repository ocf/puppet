class ocf::networking(
    $bridge     = false,

    $ipaddress  = $::ipHostNumber,  # lint:ignore:variable_is_lowercase
    $netmask    = '255.255.255.0',
    $gateway    = '169.229.226.1',

    $ipaddress6 = regsubst($::ipHostNumber, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$', '2607:f140:8801::1:\4'),  # lint:ignore:variable_is_lowercase
    $netmask6   = '64',
    $gateway6   = '2607:f140:8801::1',

    $domain      = 'ocf.berkeley.edu',
    $nameservers = ['2607:f140:8801::1:22', '169.229.226.22', '128.32.206.12'],
) {
  $fqdn = $::clientcert
  $hostname = regsubst($::clientcert, '^([\w-]+)\..*$', '\1')

  # packages
  if $bridge {
    package { 'bridge-utils': }

    # For unknown reasons, this must be set on kernel 4.9, but not 4.7 or below (rt#5849)
    sysctl { 'net.bridge.bridge-nf-call-iptables': value => '0' }
  }

  package { 'resolvconf':
    ensure => purged,
  }

  if $::lsbdistcodename == 'jessie' {
    if $bridge {
      $iface = 'br0'
      $br_iface = 'eth0'
    } else {
      $iface = 'eth0'
    }
  } else {
    # Find the first network interface that starts with 'en', since those are
    # ethernet interfaces. (Won't work for the raspberry pi, since it uses wifi)
    $ifaces_array = split($::interfaces, ',')
    $br_iface = grep($ifaces_array, 'en.+')[0]

    # If using bridged networking, use the interface found above as the
    # interface being bridged to.
    if $bridge {
      $iface = 'br0'
    } else {
      $iface = $br_iface
    }
  }

  # network configuration
  file {
    '/etc/network/interfaces':
      content => template('ocf/networking/interfaces.erb');
    '/etc/hostname':
      content => "${hostname}\n";
    '/etc/hosts':
      content => template('ocf/networking/hosts.erb');
    '/etc/resolv.conf':
      content => template('ocf/networking/resolv.conf.erb'),
      require => Package['resolvconf'];
  }
}
