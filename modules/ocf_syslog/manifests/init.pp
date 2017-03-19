class ocf_syslog {
  package { 'rsyslog': }

  service { 'rsyslog':
    require => [
      Package['rsyslog'],
      File['/etc/rsyslog.d/ocf.conf'],
    ],
  }

  file {
    '/var/log/remote':
      ensure => directory;

    '/etc/rsyslog.d/ocf.conf':
      source  => 'puppet:///modules/ocf_syslog/ocf.conf',
      notify  => Service['rsyslog'],
      require => Package['rsyslog'];

    '/etc/logrotate.d/ocf-syslog':
      source  => 'puppet:///modules/ocf_syslog/logrotate';
  }
}
