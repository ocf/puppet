class ocf_desktop::drivers {
  class { 'ocf::apt::i386':
    stage => first,
  }

  # install proprietary nvidia drivers
  if $::gfx_brand == 'nvidia' {
    package { ['nvidia-driver', 'libgl1-nvidia-glx:i386']:; }

    file { '/etc/X11/xorg.conf':
      source => 'puppet:///modules/ocf_desktop/drivers/nvidia/xorg.conf';
    }
  } elsif $::gfx_brand == 'intel' {
    package { ['libgl1-mesa-glx:i386']:; }
  }

  # this is used even with nvidia drivers
  package { ['libgl1-mesa-dri:i386']:; }
}
