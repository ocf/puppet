class ocf_desktop::packages {
  include ocf::extrapackages
  include ocf::packages::docker

  # Install packages specific to desktops
  #
  # In general, prefer to install packages to ocf::packages so that they are
  # also available on the login and web servers; this is helpful to users, and
  # avoids surprises
  #
  # This list should be used only for packages that don't make sense on a
  # server (such as gimp)
  package {
    # applications
    ['arandr', 'atom', 'claws-mail', 'eog', 'evince-gtk', 'filezilla',
      'florence', 'freeplane', 'geany', 'gimp', 'gnome-calculator', 'gparted',
      'hexchat', 'imagej', 'inkscape', 'lyx', 'mssh', 'mumble', 'numlockx',
      'simple-scan', 'ssh-askpass-gnome', 'texmaker', 'texstudio', 'vlc',
      'xarchiver', 'xcape', 'xterm', 'zenmap']:;
    # desktop
    ['desktop-base', 'anacron', 'accountsservice', 'desktop-file-utils',
      'gnome-icon-theme', 'redshift', 'xfce4-whiskermenu-plugin']:;
    # desktop helpers
    ['libimage-exiftool-perl']:;
    # display manager
    ['lightdm', 'lightdm-gtk-greeter', 'libpam-trimspaces']:;
    # fonts
    ['cm-super', 'fonts-croscore', 'fonts-crosextra-caladea',
      'fonts-crosextra-carlito', 'fonts-hack-otf', 'fonts-inconsolata',
      'fonts-linuxlibertine', 'fonts-noto-unhinted', 'fonts-unfonts-core',
      'ttf-ancient-fonts', ]:;
    # FUSE
    ['fuse', 'exfat-fuse']:;
    # games
    ['armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music']:;
    # graphics/plotting
    ['r-cran-rgl', 'jupyter-qtconsole', 'rstudio']:;
    # input method editors
    ['fcitx', 'fcitx-libpinyin', 'fcitx-rime', 'fcitx-hangul', 'fcitx-mozc']:;
    # nonfree packages
    ['firmware-linux', 'ttf-mscorefonts-installer', 'nvidia-smi']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # performance improvements
    ['preload']:;
    # security tools
    ['scdaemon']:;
    # utilities
    ['wakeonlan']:;
    # Xorg
    ['xclip', 'xsel', 'xserver-xorg', 'xscreensaver']:;
  }

  # Remove some packages
  package {
    # causes the fcitx menu to vanish
    'ayatana-indicator-application':
      ensure => purged;
    # dependencies conflict with backports
    'remmina':
      ensure => purged;
    # causes gid conflicts
    'sane-utils':
      ensure => purged;
    # xpdf takes over as default sometimes
    'xpdf':
      ensure => purged;
  }

  # install packages without recommends
  ocf::repackage {
    'brasero':
      recommends => false;
    'fcitx-table-wubi':
      recommends => false;
    'gedit':
      recommends => false;
    ['libreoffice-calc', 'libreoffice-draw', 'libreoffice-gnome', 'libreoffice-gtk3', 'libreoffice-impress', 'libreoffice-pdfimport', 'libreoffice-writer', 'ure']:
      recommends  => false,
      backport_on => stretch;
    'thunar':
      recommends => false;
    ['virt-manager', 'virt-viewer']:
      recommends => false;
  }

  # Install libegl1-mesa-dev from stretch-backports so that libgtk-3-dev can be
  # properly installed
  ocf::repackage {
    'libegl1-mesa-dev':
      backport_on => 'stretch',
      before      => Package['libgtk-3-dev'];
  }
}
