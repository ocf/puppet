class ocf_desktop::packages {
  include ocf::extrapackages

  package {
    # remove accidentally-installed packages
    ['php5', 'libapache2-mod-php5', 'apache2']:
      ensure => purged;
  }

  # install packages specific to desktops
  #
  # in general, prefer to install packages to ocf::packages so that they are
  # also available on the login and web servers; this is helpful to users, and
  # avoids surprises
  #
  # this list should be used only for packages that don't make sense on a
  # server (such as gimp)
  package {
    # applications
    ['claws-mail', 'geany', 'filezilla', 'inkscape', 'mssh', 'numlockx', 'remmina', 'simple-scan', 'vlc', 'zenmap', 'gimp', 'gparted', 'evince-gtk', 'galculator']:;
    # desktop
    ['desktop-base', 'desktop-file-utils', 'gpicview', 'xarchiver', 'xterm', 'lightdm', 'accountsservice']:;
    # fonts
    ['cm-super', 'fonts-inconsolata', 'fonts-liberation', 'fonts-linuxlibertine']:;
    # games
    ['armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music']:;
    # useful tools
    ['lyx', 'texmaker']:;
    # nonfree packages
    ['firmware-linux', 'flashplugin-nonfree', 'ttf-mscorefonts-installer']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # performance improvements
    ['preload', 'readahead-fedora']:;
    # Xorg
    ['xserver-xorg', 'xscreensaver']:;
    # FUSE
    ['fuse', 'exfat-fuse']:
  }

  # remove some packages
  package {
    # causes gid conflicts
    'sane-utils':
      ensure  => purged;
    # no longer used
    [ 'rusers', 'rusersd' ]:
      ensure  => purged;
    # xpdf takes over as default sometimes
    'xpdf':
      ensure  => purged;
  }

  # install packages without recommends
  ocf::repackage {
    'brasero':
      recommends  => false;
    'gedit':
      recommends  => false;
    ['libreoffice-calc', 'libreoffice-draw', 'libreoffice-gnome', 'libreoffice-impress', 'libreoffice-writer', 'ure']:
      recommends  => false,
      backport_on => 'wheezy';
    'thunar':
      recommends  => false;
    ['virt-manager', 'virt-viewer']:
      recommends  => false;
  }
}
