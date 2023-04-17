class ocf::smart {
  if !str2bool($::is_virtual) {
    file {
      '/usr/local/sbin/smartmon.sh':
        source  => 'puppet:///modules/ocf/smartmon.sh',
        owner   => root,
        group   => root,
        mode    => '0755',
        require => Package['smartmontools'];
    }
    cron {
      'smartmon':
        command => '/usr/local/sbin/smartmon.sh > /srv/prometheus/smartmon.prom',
        minute  => '*/5',
        require => [Package['smartmontools'], File['/usr/local/sbin/smartmon.sh']];
    }
  }
}
