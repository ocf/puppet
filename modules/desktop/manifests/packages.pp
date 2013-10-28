class desktop::packages {

  # install common and extra packages but not packages for login server
  class { 'common::packages':
    extra  => true,
    login  => false
  }

  # install a lot of other packages
  package {
    # applications
    [ 'claws-mail', 'geany', 'gftp-gtk', 'inkscape', 'mssh', 'numlockx', 'remmina', 'simple-scan', 'vlc', 'zenmap' ]:;
    # desktop
    [ 'desktop-base', 'desktop-file-utils', 'gpicview', 'lxappearance', 'lxde-core', 'lxde-icon-theme', 'lxtask', 'lxterminal', 'xarchiver', 'xterm' ]:;
    # fonts
    [ 'cm-super', 'ttf-inconsolata', 'ttf-liberation', 'ttf-linux-libertine' ]:;
    # games
    [ 'armagetronad', 'gl-117', 'gnome-games', 'wesnoth', 'wesnoth-music' ]:;
    # lyx
    'lyx':;
	# programming environments
	[ 'python3', 'python3-tk' ]:;
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
    # reportedly buggy as default PDF reader
    [ 'evince', 'evince-gtk', 'xpdf' ]:
      ensure  => purged,
      require => Package[ 'acroread' ];
    # should not be default PDF reader
    'gimp':
      ensure  => purged;
    # no longer used
    [ 'rusers', 'rusersd' ]:
      ensure  => purged
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
