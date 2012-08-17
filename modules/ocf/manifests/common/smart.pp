class ocf::common::smart {

  # facter currently outputs strings not booleans
  # see http://projects.puppetlabs.com/issues/3704
  if $::is_virtual == 'false' {

    # install smartmontools
    package { 'smartmontools': }
    # enable smartd
    file { '/etc/default/smartmontools':
      content => 'start_smartd=yes',
      require => Package['smartmontools']
    }
    # start smartd
    service { 'smartmontools':
      subscribe => File['/etc/default/smartmontools'],
      require   => Package['smartmontools']
    }

  }

  else {

    package { 'smartmontools':
      ensure => purged
    }

  }

}
