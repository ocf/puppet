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
    ['arandr', 'atom', 'claws-mail', 'eog', 'evince-gtk', 'filezilla', 'galculator', 'geany', 'gimp', 'gparted', 'hexchat', 'inkscape', 'lyx', 'mssh', 'mumble', 'numlockx', 'remmina', 'simple-scan', 'texmaker', 'texstudio', 'vlc', 'xarchiver', 'xterm', 'zenmap']:;
    # desktop
    ['desktop-base', 'anacron', 'accountsservice', 'desktop-file-utils', 'redshift', 'xfce4-whiskermenu-plugin']:;
    # display manager
    ['lightdm', 'lightdm-gtk-greeter', 'libpam-trimspaces']:;
    # fonts
    ['cm-super', 'fonts-croscore', 'fonts-crosextra-caladea', 'fonts-crosextra-carlito', 'fonts-inconsolata', 'fonts-linuxlibertine', 'fonts-noto-unhinted', 'fonts-unfonts-core', 'ttf-ancient-fonts']:;
    # FUSE
    ['fuse', 'exfat-fuse']:;
    # games
    ['armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music']:;
    # nonfree packages
    ['firmware-linux', 'ttf-mscorefonts-installer', 'nvidia-smi']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # performance improvements
    ['preload']:;
    # Xorg
    ['xserver-xorg', 'xclip', 'xscreensaver']:;
    # R packages for rstudio
    ['r-cran-data.table', 'r-cran-dplyr', 'r-cran-ggplot2', 'r-cran-jsonlite', 'r-cran-lubridate', 'r-cran-magrittr', 'r-cran-markdown', 'r-cran-rmysql', 'r-cran-stringr', 'r-cran-tidyr', 'r-cran-xml2', 'r-cran-zoo']:;
  }

  # Packages that only work on jessie
  if $::lsbdistcodename == 'jessie' {
    package {
      [
        'readahead-fedora',
      ]:;
    }
  }

  # Install rstudio, custom built to work with libssl1.0.2 and run on stretch.
  # TODO: Remove libgstreamer0.10-0 and libgstreamer-plugins-base0.10-0 once
  # rstudio is packaged officially for stretch. These two packages are installed
  # from our apt repo (ported from jessie) and are dependencies of rstudio until
  # rstudio updates to libgstreamer1.0-0 and libgstreamer-plugins-base1.0-0.
  package { 'rstudio':; }

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
