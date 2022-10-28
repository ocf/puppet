class ocf_desktop::packages {
  include ocf::extrapackages
  include ocf::packages::fonts
  include ocf::packages::atom

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
    ['arandr', 'clementine', 'eog', 'evince',
      'filezilla', 'freeplane', 'geany', 'gimp',
      'gnome-calculator', 'gparted', 'hexchat', 'imagej', 'inkscape', 'lyx',
      'musescore3', 'mpv', 'mssh', 'mumble', 'numlockx',
      'simple-scan', 'ssh-askpass-gnome', 'texmaker',
      'texstudio', 'tigervnc-viewer', 'vlc', 'xarchiver', 'xcape', 'xournal',
      'xterm']:;
    # desktop
    ['desktop-base', 'anacron', 'accountsservice', 'arc-theme',
      'desktop-file-utils', 'gnome-icon-theme', 'paper-icon-theme', 'redshift',
      'xfce4-whiskermenu-plugin']:;
    # desktop helpers
    ['libimage-exiftool-perl']:;
    # development:
    ['openjdk-17-jdk']:;
    # display manager
    ['lightdm', 'lightdm-gtk-greeter']:;
    # games
    # graphics/plotting
    ['r-cran-rgl', 'jupyter-qtconsole']:;
    # input method editors
    ['ibus', 'ibus-libpinyin', 'ibus-rime', 'ibus-hangul', 'ibus-mozc' ]:;
    # nonfree packages
    ['firmware-linux']:;
    # notifications
    ['libnotify-bin', 'notification-daemon']:;
    # security tools
    ['scdaemon', 'yubikey-manager']:;
    # utilities
    ['wakeonlan']:;
    # Xorg
    ['xclip', 'xdotool', 'xsel', 'xserver-xorg', 'xscreensaver', 'freerdp2-x11']:;
    # Matchbox is what we use on our RPi
    ['matchbox-keyboard']:;
    # sshfs depends on fuse3 on bullseye
    ['fuse3']:;
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
    ['libreoffice-calc', 'libreoffice-draw', 'libreoffice-gnome', 'libreoffice-gtk3', 'libreoffice-impress', 'libreoffice-writer', 'ure']:
      recommends  => false,
      backport_on => stretch;
    'thunar':
      recommends => false;
    ['virt-manager', 'virt-viewer']:
      recommends => false;
  }


  exec {
    'disable chrome password store':
      command => "perl -pi -e 's/(\/usr\/bin\/google-chrome[a-zA-Z-]*)( |$)(?!--password-store=basic)/\1 --password-store=basic\2/' /usr/share/applications/google-chrome*",
      unless  => "grep -E '/usr/bin/google-chrome[a-zA-Z-]* --password-store=basic' /usr/share/applications/google-chrome*",
      require => Package['google-chrome-stable'];
  }
}
