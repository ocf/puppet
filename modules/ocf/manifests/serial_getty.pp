class ocf::serial_getty {
  if str2bool($::is_virtual) or member(hiera('classes'), 'ocf_kvm') {
    service { 'serial-getty@ttyS0':
      enable   => true,
      provider => systemd,
      require  => Package['systemd-sysv'],
    } ~>
    exec { 'systemctl start serial-getty@ttyS0':
      refreshonly => true,
    }
  }
}
