class desktop::drivers {
  service { 'lightdm':
    require => Package['lightdm'];
  }

  # install proprietary nvidia drivers
  if $::gfx_brand == 'nvidia' {
    package { ['nvidia-driver', 'libgl1-nvidia-glx:i386']:; }

    file { '/etc/X11/xorg.conf':
      source => 'puppet:///modules/desktop/drivers/nvidia/xorg.conf',
      notify => Service['lightdm'];
    }
  } elsif $::gfx_brand == 'intel' {
    package { ['libgl1-mesa-glx:i386']:; }
  }

  # this is used even with nvidia drivers
  package { ['libgl1-mesa-dri:i386']:; }
}
