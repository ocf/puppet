class ocf::serial_getty {
  service { 'serial-getty@ttyS0':
    ensure   => running,
    enable   => true,
    provider => systemd,
    require  => Package['systemd-sysv'],
  }
}
