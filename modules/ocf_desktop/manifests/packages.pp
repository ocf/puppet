class ocf_desktop::packages {
  include ocf::extrapackages
  include ocf::packages::docker
  include ocf::packages::fahclient
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
    ['arandr', 'blender', 'claws-mail', 'clementine', 'eog', 'evince',
      'filezilla', 'freeplane', 'geany', 'gimp',
      'gnome-calculator', 'gparted', 'hexchat', 'imagej', 'inkscape', 'lyx',
      'musescore3', 'mpv', 'mssh', 'mumble', 'numlockx',
      'simple-scan', 'ssh-askpass-gnome', 'texmaker',
      'texstudio', 'vlc', 'xarchiver', 'xcape', 'xournal', 'xterm']:;
    # desktop
    ['desktop-base', 'anacron', 'accountsservice', 'arc-theme',
      'desktop-file-utils', 'gnome-icon-theme', 'paper-icon-theme', 'redshift',
      'xfce4-whiskermenu-plugin']:;
    # desktop helpers
    ['libimage-exiftool-perl']:;
    # display manager
    ['lightdm', 'lightdm-gtk-greeter', 'libpam-trimspaces']:;
    # games
    ['armagetronad', 'freeciv', 'gl-117', 'gnome-games', 'minecraft-launcher', 'minetest', 'redeclipse',
      'supertuxkart', 'wesnoth', 'wesnoth-music']:;
    # graphics/plotting
    ['r-cran-rgl', 'jupyter-qtconsole', 'rstudio']:;
    # input method editors
    ['fcitx', 'fcitx-libpinyin', 'fcitx-rime', 'fcitx-hangul', 'fcitx-mozc']:;
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
  }

  if $::lsbdistcodename == 'stretch' {
    package {
      [
        # preload hasn't been updated since 2009, and I'm not sure we really
        # get anything out of it in terms of performance improvements at this
        # point anyway.
        'preload',

        # Zenmap depends on Python 2 and is therefore no longer in bullseye
        'zenmap',

        # FUSE and exfat
        'fuse',
        'exfat-fuse',

        # Florence was removed from bullseye due to deprecated dependency
        # We should find an alternative
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=947521
        'florence',
      ]:;
    }
  }
  if $::lsbdistcodename == 'buster' {
    package {
      [
        # Zenmap depends on Python 2 and is therefore no longer in bullseye
        'zenmap',

        # FUSE and exfat
        'fuse',
        'exfat-fuse',

        # Florence was removed from bullseye due to deprecated dependency
        # We should find an alternative
        # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=947521
        'florence',
      ]:;
    }
  }
  if $::lsbdistcodename == 'bullseye' {
    package {
      [
        # OpenJDK 17 (LTS) is in bullseye
        'openjdk-17-jdk',

        # Matchbox is what we use on our RPi
        'matchbox-keyboard',

        # x4vncviewer is no longer present
        'tigervnc-viewer',

        # sshfs depends on fuse3 on bullseye
        'fuse3',
      ]:;
    }
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
