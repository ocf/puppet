class ocf_desktop::drivers {
  include ocf::apt::i386

  # install proprietary nvidia drivers
  if $::gfx_brand == 'nvidia' {
    # Install nvidia-driver from backports so that it loads properly
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=903770
    ocf::repackage { ['nvidia-driver', 'libgl1-nvidia-glx:i386']:
      backport_on => 'stretch';
    }
    package { ['xserver-xorg-video-nvidia', 'nvidia-settings', 'nvidia-cuda-toolkit', 'nvidia-cuda-mps']:; }

    file { '/etc/X11/xorg.conf':
      source => 'puppet:///modules/ocf_desktop/drivers/nvidia/xorg.conf';
    }

    augeas { 'grub_nomodeset':
      context => '/files/etc/default/grub',
      changes => [
        # Add nomodeset to grub command-line options (quiet is the default)
        'set GRUB_CMDLINE_LINUX_DEFAULT \'"quiet nomodeset"\'',
      ],
      notify  => Exec['update-grub'],
    }
  } elsif $::gfx_brand == 'intel' {
    package { ['libgl1-mesa-glx:i386']:; }
  }

  # this is used even with nvidia drivers
  package { ['libgl1-mesa-dri:i386']:; }
}
