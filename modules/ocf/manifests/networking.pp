class ocf::networking(
    $bridge     = false,

    $ipaddress  = $::ipHostNumber,
    $netmask    = '255.255.255.0',
    $gateway    = '169.229.226.1',

    $ipaddress6 = regsubst($::ipHostNumber, '^(\d+)\.(\d+)\.(\d+)\.(\d+)$', '2607:f140:8801::1:\4'),
    $netmask6   = '64',
    $gateway6   = '2607:f140:8801::1',

    $domain      = 'ocf.berkeley.edu',
    $nameservers = ['169.229.226.22', '128.32.206.12', '128.32.136.9'],
) {
  $fqdn = $::clientcert
  $hostname = regsubst($::clientcert, '^([\w-]+)\..*$', '\1')

  # packages
  if $bridge {
    package { 'bridge-utils': }
  }

  package { 'resolvconf':
    ensure => purged,
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
