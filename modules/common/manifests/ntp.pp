class common::ntp( $physical = false ) {

  # install ntp
  package { 'ntp': }

  # provide ntp config
  if ! $physical {
    file { '/etc/ntp.conf':
      source  => 'puppet:///modules/common/ntp.conf',
      require => Package['ntp'],
    }
  } else {
    file { '/etc/ntp.conf':
      content => template('common/ntp.conf.erb'),
      require => Package['ntp'],
    }
  }

  # start ntp
  service { 'ntp':
    subscribe => File['/etc/ntp.conf'],
    require   => Package['ntp'],
  }

}
