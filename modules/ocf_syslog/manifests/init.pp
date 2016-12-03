class ocf_syslog {
  ocf::repackage { 'rsyslog':
    # TCP logging is broken in jessie :\
    backport_on => jessie,
  }

  service { 'rsyslog':
    require => [
      Ocf::Repackage['rsyslog'],
      File['/etc/rsyslog.d/ocf.conf'],
    ],
  }

  file {
    '/var/log/remote':
      ensure => directory;

    '/etc/rsyslog.d/ocf.conf':
      source  => 'puppet:///modules/ocf_syslog/ocf.conf',
      notify  => Service['rsyslog'],
      require => Ocf::Repackage['rsyslog'];

    '/etc/logrotate.d/ocf-syslog':
      source  => 'puppet:///modules/ocf_syslog/logrotate';
  }
}
