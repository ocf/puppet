class ocf::common::smart {

  if ( ! $is_virtual ) {

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

}
