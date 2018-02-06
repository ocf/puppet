class ocf_syslog {
  # rsyslog package and service are already defined in ocf::logging

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
