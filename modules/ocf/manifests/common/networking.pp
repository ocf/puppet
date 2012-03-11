class ocf::common::networking( $hosts = true, $interfaces = true, $resolv = true, $octet = undef ) {

  # provide hostname
  file { '/etc/hostname':
    content => "$::hostname"
  }

  service {'networking':}

  if $hosts {
    # provide /etc/hosts
    file { '/etc/hosts':
      content => template('ocf/common/networking/hosts.erb');
    }
  }

  # if interfaces provided
  if $interfaces {
    # provide network interfaces
    file { '/etc/network/interfaces':
      content => template('ocf/common/networking/interfaces.erb'),
      notify  => Service['networking']
    }
    # start network interfaces
    exec { 'ifup -a':
      refreshonly => true,
      subscribe   => File['/etc/network/interfaces']
    }
  }

  # if IP address statically assigned and resolv.conf provided
  if $octet != undef and $resolv {

    # if interfaces provided
    if $interfaces {
      # provide resolv.conf
      file { '/etc/resolv.conf':
        content => template('ocf/common/networking/resolv.conf.erb'),
        require => Exec['ifup -a']
      }
    }

    # if interfaces not provided
    if ! $interfaces {
      # provide resolv.conf
      file { '/etc/resolv.conf':
        content => template('ocf/common/networking/resolv.conf.erb'),
      }
      # start network interfaces
      exec { 'ifup -a':
        subscribe => File['/etc/resolv.conf']
      }
    }

  }

}
