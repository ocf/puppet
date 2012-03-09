class ocf::desktop::xsession {

  require ocf::desktop::packages

  # Xsession configuration
  file {
    # provide custom Xsession script to populate desktop
    '/etc/X11/Xsession.d/95ocf':
      source  => 'puppet:///modules/ocf/desktop/xsession/Xsession',
      require => File['/opt/share/xsession'];
    # provide list of desktops
    '/opt/share/puppet/desktop_list':
      source  => 'puppet:///modules/ocf/desktop/desktop_list';
    # provide printing and other notification script daemon
    '/opt/share/puppet/notify.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/desktop/xsession/notify.sh',
      require => File['/opt/share/puppet/desktop_list'];
    # provide share directory with icons and wallpapers
    '/opt/share/xsession':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///contrib/desktop/xsession',
      require => Class['ocf::common::puppet'];
    # enforce list of possible xsessions
    '/usr/share/xsessions':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///modules/ocf/desktop/xsession/xsessions'
  }

  # gdm configuration
  # install gdm3 as login manager with minimal bloat
  # metacity is needed to work around gdm hourglass bug
  ocf::repackage { [ 'gdm3', 'gnome-settings-daemon', 'metacity' ]:
    recommends => false
  }
  # provide gdm config
  file {
    # login interface
    '/etc/gdm3/greeter.gconf-defaults':
      source  => 'puppet:///modules/ocf/desktop/xsession/gdm/greeter.gconf-defaults',
      require => Ocf::Repackage['gdm3'];
    # ocf icon
    '/usr/share/icons/ocf.png':
      backup  => false,
      source  => 'puppet:///contrib/desktop/ocf.png';
    # kill child processes on logout
    '/etc/gdm3/PostSession/Default':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/desktop/xsession/gdm/PostSession',
      require => Ocf::Repackage['gdm3'];
  }

  # polkit configuration
  # prevent privileged actions except mounting/ejecting external media
  file {  '/usr/share/polkit-1/actions':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    backup  => false,
    source  => 'puppet:///modules/ocf/desktop/xsession/polkit'
  }

  # lxde configuration
  file {
    # provide lxde wallpaper configuration
    '/usr/share/lxde/pcmanfm/LXDE.conf':
      source  => 'puppet:///modules/ocf/desktop/xsession/lxde/LXDE.conf';
    # provide lxterminal configuration to fix transparency bug
    '/usr/share/lxterminal/lxterminal.conf':
      source  => 'puppet:///modules/ocf/desktop/xsession/lxde/lxterminal.conf';
  }

  # lxde logout configuration
  file {
    # replace logout binary with one compiled without dbus support
    '/usr/local/bin/lxsession-logout':
      mode    => '0755',
      backup  => false,
      source  => 'puppet:///contrib/desktop/lxsession-logout';
    # provide logout banner
    '/opt/share/xsession/logout-banner.png':
      backup  => false,
      source  => 'puppet:///contrib/desktop/logout-banner.png';
    # replace logout script configuration
    '/usr/bin/lxde-logout':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/desktop/xsession/lxde/lxde-logout'
  }

  # font configuration
  file {
    # enable font auto-hinting
    '/etc/fonts/conf.d/10-autohint.conf':
      ensure => symlink,
      target => '/etc/fonts/conf.avail/10-autohint.conf';
    # enable font sub-pixel rendering
    '/etc/fonts/conf.d/10-sub-pixel-rgb.conf':
      ensure => symlink,
      target => '/etc/fonts/conf.avail/10-sub-pixel-rgb.conf'
  }

  # xscreensaver configuration
  package { 'xscreensaver': }
  file { '/etc/X11/app-defaults/XScreenSaver':
    mode    => '0755',
    backup  => false,
    source  => 'puppet:///modules/ocf/desktop/xsession/XScreenSaver',
    require => Package['xscreensaver']
  }

}
