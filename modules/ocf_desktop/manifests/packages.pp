class ocf_desktop::packages {
  include ocf::extrapackages
  include ocf::packages::docker
  include ocf::packages::fonts

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
    ['arandr', 'atom', 'blender', 'claws-mail', 'eog', 'evince', 'filezilla',
      'florence', 'freeplane', 'geany', 'gimp', 'gnome-calculator', 'gparted',
      'hexchat', 'imagej', 'inkscape', 'lyx', 'musescore', 'mpv', 'mssh',
      'mumble', 'numlockx', 'simple-scan', 'ssh-askpass-gnome', 'texlive',
      'texlive-bibtex-extra', 'texlive-extra-utils', 'texlive-humanities',
      'texlive-latex-extra', 'texlive-publishers', 'texlive-science', 'texmaker',
      'texstudio', 'vlc', 'xarchiver', 'xcape', 'xournal', 'xterm', 'zenmap']:;
    # desktop
    ['desktop-base', 'anacron', 'accountsservice', 'arc-theme',
      'desktop-file-utils', 'gnome-icon-theme', 'paper-icon-theme', 'redshift',
      'xfce4-whiskermenu-plugin']:;
    # desktop helpers
    ['libimage-exiftool-perl']:;
    # display manager
    ['lightdm', 'lightdm-gtk-greeter', 'libpam-trimspaces']:;
    # FUSE
    ['fuse', 'exfat-fuse']:;
    # games
    ['armagetronad', 'gl-117', 'gnome-games', 'minecraft-launcher', 'redeclipse',
      'wesnoth', 'wesnoth-music']:;
    # graphics/plotting
    ['r-cran-rgl', 'jupyter-qtconsole', 'rstudio']:;
    # input method editors
    ['fcitx', 'fcitx-libpinyin', 'fcitx-rime', 'fcitx-hangul', 'fcitx-mozc']:;
    # nonfree packages
    ['firmware-linux']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # security tools
    ['scdaemon']:;
    # utilities
    ['wakeonlan']:;
    # Xorg
    ['xclip', 'xsel', 'xserver-xorg', 'xscreensaver', 'rdesktop']:;
  }

  # Remove some packages
  package {
    default:
      ensure => purged;
    # causes the fcitx menu to vanish
    'ayatana-indicator-application':;
    # meant for personal machines, and has invasive prompt
    'gnome-keyring':;
    # dependencies conflict with backports
    'remmina':;
    # causes gid conflicts
    'sane-utils':;
    # xpdf takes over as default sometimes
    'xpdf':;
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

  ocf::repackage {
    # Install libegl1-mesa-dev from stretch-backports so that libgtk-3-dev can be
    # properly installed
    'libegl1-mesa-dev':
      backport_on => 'stretch',
      before      => Package['libgtk-3-dev'];
    'libgl1-mesa-glx':
      backport_on => 'stretch',
      before      => Package['gnome-games'];
    'libgl1-mesa-glx:i386':
      backport_on => 'stretch',
      before      => Package['steam'];
    # tilix is only available in backports
    'tilix':
      backport_on => 'stretch';
  }
}
