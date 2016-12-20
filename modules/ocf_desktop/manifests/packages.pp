class ocf_desktop::packages {
  include ocf::extrapackages

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
    ['anacron', 'arandr', 'claws-mail', 'geany', 'filezilla', 'inkscape', 'mssh', 'numlockx', 'remmina', 'simple-scan', 'vlc', 'zenmap', 'gimp', 'gparted', 'evince-gtk', 'galculator', 'hexchat', 'atom']:;
    # desktop
    ['desktop-base', 'desktop-file-utils', 'eog', 'xarchiver', 'xterm', 'lightdm', 'accountsservice', 'redshift', 'xfce4-whiskermenu-plugin']:;
    # fonts
    ['cm-super', 'fonts-croscore', 'fonts-crosextra-caladea', 'fonts-crosextra-carlito', 'fonts-inconsolata', 'fonts-linuxlibertine', 'fonts-unfonts-core', 'ttf-ancient-fonts']:;
    # games
    ['armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music']:;
    # useful tools
    ['lyx', 'texmaker']:;
    # nonfree packages
    ['firmware-linux', 'flashplugin-nonfree', 'ttf-mscorefonts-installer']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # performance improvements
    ['preload']:;
    # Xorg
    ['xserver-xorg', 'xscreensaver', 'xclip']:;
    # FUSE
    ['fuse', 'exfat-fuse']:
  }

  # Packages that only work on jessie
  if $::lsbdistcodename == 'jessie' {
    package {
      [
        # TODO: Put rstudio package in apt repo
        'rstudio',
        'lightdm-gtk-greeter-ocf',
        'readahead-fedora',
      ]:;
    }
  } else {
    # Packages only on stretch
    # TODO: Apply kpengboy's whitespace patch to this
    package { 'lightdm-gtk-greeter':; }
  }

  # remove some packages
  package {
    # causes gid conflicts
    'sane-utils':
      ensure  => purged;
    # xpdf takes over as default sometimes
    'xpdf':
      ensure  => purged;
  }

  # install packages without recommends
  ocf::repackage {
    'brasero':
      recommends => false;
    'gedit':
      recommends => false;
    ['libreoffice-calc', 'libreoffice-draw', 'libreoffice-gnome', 'libreoffice-impress', 'libreoffice-writer', 'ure']:
      recommends => false;
    'thunar':
      recommends => false;
    ['virt-manager', 'virt-viewer']:
      recommends => false;
  }
}
