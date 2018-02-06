class ocf::logging {
  package { 'rsyslog': }

  service { 'rsyslog':
    require => Package['rsyslog'],
  }

  augeas { 'remote-syslog':
    context => '/files/etc/rsyslog.conf',
    changes => [
      'set entry[last()+1]/selector/facility *',
      'set entry[last()]/selector/level *',
      'set entry[last()]/action/protocol @@',
      'set entry[last()]/action/hostname syslog',
      'set entry[last()]/action/port 514',
    ],
    onlyif  => "match entry[action/hostname = 'syslog'] size == 0",
    notify  => Service['rsyslog'],
    require => Package['rsyslog'],
  }
}
