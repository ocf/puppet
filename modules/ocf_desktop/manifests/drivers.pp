class ocf_desktop::drivers {
  include ocf::apt::i386

  # install proprietary nvidia drivers
  if $::gfx_brand == 'nvidia' {
    # Install nvidia-driver from backports to support the GTX 1060s in the lab
    # Only needed on jessie, since stretch has drivers that are recent (367+)
    ocf::repackage { ['nvidia-driver', 'xserver-xorg-video-nvidia', 'libgl1-nvidia-glx:i386']:
      backport_on => 'jessie',
    }

    file { '/etc/X11/xorg.conf':
      source => 'puppet:///modules/ocf_desktop/drivers/nvidia/xorg.conf';
    }
  } elsif $::gfx_brand == 'intel' {
    package { ['libgl1-mesa-glx:i386']:; }
  }

  # this is used even with nvidia drivers
  package { ['libgl1-mesa-dri:i386']:; }
}
