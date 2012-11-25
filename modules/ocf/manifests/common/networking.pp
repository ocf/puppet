class ocf::common::networking( $hosts = true, $interfaces = true, $octet = undef ) {

  # do not provide resolv.conf if using DHCP
  if $octet == undef {
    $resolv = false
  } else {
    $resolv = true
  }

  # set FQDN and hostname from SSL client certificate
  $fqdn = $::clientcert
  $hostname = regsubst($::clientcert, '^(\w+)\..*$', '\1')

  # provide hostname
  file { '/etc/hostname':
    content => $hostname,
  }

  service {'networking':}

  if $hosts {
    # provide /etc/hosts
    file { '/etc/hosts':
      content => template('ocf/common/networking/hosts.erb'),
    }
  }

  # if interfaces provided
  if $interfaces {
    # provide network interfaces
    file { '/etc/network/interfaces':
      content => template('ocf/common/networking/interfaces.erb'),
      notify  => [ Service['networking'], Exec['ifup -a'] ],
    }
    # start network interfaces
    exec { 'ifup -a':
      refreshonly => true,
    }
  }

  # if resolv.conf provided
  if $resolv {
    package { 'resolvconf':
      ensure => purged,
    }
    # provide resolv.conf
    file { '/etc/resolv.conf':
      content => template('ocf/common/networking/resolv.conf.erb'),
      require => Package['resolvconf'],
    }
  }

}
