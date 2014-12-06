class desktop::drivers {
  service { 'lightdm':
    require => Package['lightdm'];
  }

  # install proprietary nvidia drivers
  if $::gfx_brand == 'nvidia' {
    package { 'nvidia-driver':; }

    file { '/etc/X11/xorg.conf':
      source => 'puppet:///modules/desktop/drivers/nvidia/xorg.conf',
      notify => Service['lightdm'];
    }
  }
}
