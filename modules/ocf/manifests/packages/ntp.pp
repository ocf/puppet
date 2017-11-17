class ocf::packages::ntp($master = false, $peers = []) {
  # install ntp
  package { 'ntp':; }

  # provide ntp config
  if $master {
    file { '/etc/ntp.conf':
      content => template('ocf/ntp.conf.erb'),
      require => Package['ntp'],
    }

    #firewall input rule, allow ntp (123 udp/tcp)
    ocf::firewall::firewall46 {
      '101 accept all ntp':
        opts => {
          chain  => 'PUPPET-INPUT',
          proto  => ['tcp', 'udp'],
          dport  => 'ntp',
          action => 'accept',
        };
    }
  } else {
    file { '/etc/ntp.conf':
      source  => 'puppet:///modules/ocf/ntp.conf',
      require => Package['ntp'],
    }
  }

  # start ntp
  service { 'ntp':
    subscribe => File['/etc/ntp.conf'],
    require   => Package['ntp'],
  }
}
