class ocf::packages::ntp($master = false, $peers = []) {
  # install ntp
  package { 'ntp':; }

  # provide ntp config
  if $master {
    file { '/etc/ntp.conf':
      source  => 'puppet:///modules/ocf/ntp.conf',
      require => Package['ntp'],
    }
  } else {
    file { '/etc/ntp.conf':
      content => template('ocf/ntp.conf.erb'),
      require => Package['ntp'],
    }
  }

  # start ntp
  service { 'ntp':
    subscribe => File['/etc/ntp.conf'],
    require   => Package['ntp'],
  }
}
