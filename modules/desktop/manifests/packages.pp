class desktop::packages {

  # install common and extra packages but not packages for login server
  class { 'common::packages':
    extra  => true,
    login  => false,
  }

  # install backported kernel and intel driver for improved compatibility with
  # desktop integrated graphics (Haswell CPUs);
  ocf::repackage {
    "linux-image-${::architecture}":
      backports => true;
    "linux-headers-${::architecture}":
      backports => true;
  }
  if $::lsbdistcodename == 'wheezy' {
    package { 'xserver-xorg-video-intel':
      provider  => dpkg,
      ensure    => latest,
      # no official backport is available, so we use our own backported package (2014-05-24)
      source    => '/opt/share/puppet/packages/xserver-xorg-video-intel_2.21.15-2~bpo70+1_amd64.deb',
    }
  }

  file { '/opt/share/puppet/packages':
    ensure  => directory,
    source  => 'puppet:///contrib/desktop/packages',
    recurse => true
  }

  # install a lot of other packages
  package {
    # applications
    [ 'evince-gtk', 'claws-mail', 'geany', 'gftp-gtk', 'filezilla', 'inkscape', 'mssh', 'numlockx', 'remmina', 'simple-scan', 'vlc', 'zenmap', 'gimp' ]:;
    # desktop
    [ 'desktop-base', 'desktop-file-utils', 'gpicview', 'lxappearance', 'lxde-core', 'lxde-icon-theme', 'lxtask', 'lxterminal', 'xarchiver', 'xterm', 'lightdm', 'accountsservice', 'xfce4', 'xfce4-goodies' ]:;
    # fonts
    [ 'cm-super', 'fonts-inconsolata', 'fonts-liberation', 'fonts-linuxlibertine' ]:;
    # games
    [ 'armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music' ]:;
    # useful tools
    [ 'lyx', 'texmaker' ]:;
    # programming environments
    [ 'python3-tk', 'default-jdk', 'virtualbox' ]:;
    # nonfree packages
    [ 'firmware-linux', 'flashplugin-nonfree', 'ttf-mscorefonts-installer' ]:;
    # notifications
    [ 'libnotify-bin', 'notification-daemon' ]:;
    # performance improvements
    [ 'preload', 'readahead-fedora' ]:;
    # Xorg
    'xserver-xorg':
  }

  # remove some packages
  package {
    # causes gid conflicts
    'sane-utils':
      ensure  => purged;
    # no longer used
    [ 'rusers', 'rusersd' ]:
      ensure  => purged;
    # xpdf takes over as defauult sometimes
    'xpdf':
      ensure  => purged;
  }

  # install backported packages
  ocf::repackage {
    'gitk': # git is backported, so we need backported gitk
      backports => true,
      require   => Ocf::Repackage['git'];
  }

  # install packages without recommends
  ocf::repackage {
    'brasero':
      recommends => false;
    'gedit':
      recommends => false;
    [ 'libreoffice-calc', 'libreoffice-draw', 'libreoffice-gnome', 'libreoffice-impress', 'libreoffice-writer', 'ure' ]:
      recommends => false,
      backports  => true;
    'thunar':
      recommends => false;
    [ 'virt-manager', 'virt-viewer' ]:
      recommends => false
  }

}
