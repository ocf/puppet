class ocf::systemd {
  exec { 'systemd-reload':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
    require     => Package['systemd-sysv'],
  }
}
