class common::ntp {

  # facter currently outputs strings not booleans
  # see http://projects.puppetlabs.com/issues/3704
  if $::is_virtual == 'false' {

    # install ntp
    package { 'ntp': }

    # provide ntp config
    file { '/etc/ntp.conf':
      source  => 'puppet:///modules/common/ntp.conf',
      require => Package['ntp']
    }

    # start ntp
    service { 'ntp':
      subscribe => File['/etc/ntp.conf'],
      require   => Package['ntp']
    }

  }

  else {

    package { 'ntp':
      ensure => purged
    }

  }

}
