class ocf::serial_getty {
  service { 'serial-getty@ttyS0':
    enable   => true,
    provider => systemd,
    require  => Package['systemd-sysv'],
  } ~>
  exec { 'systemctl start serial-getty@ttyS0':
    refreshonly => true,
  }
}
