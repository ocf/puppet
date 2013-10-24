class common::ntp {

  # install ntp
  package { 'ntp': }

  # provide ntp config
  file { '/etc/ntp.conf':
    source  => 'puppet:///modules/common/ntp.conf',
    require => Package['ntp'],
  }

  # start ntp
  service { 'ntp':
    subscribe => File['/etc/ntp.conf'],
    require   => Package['ntp'],
  }

}
