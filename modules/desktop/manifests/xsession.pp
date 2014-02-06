class desktop::xsession {

  require desktop::packages

  # Xsession configuration
  file {
    # provide custom Xsession script to populate desktop
    '/etc/X11/Xsession.d/95ocf':
      source  => 'puppet:///modules/desktop/xsession/Xsession',
      require => File['/opt/share/xsession'];
    # provide list of desktops
    '/opt/share/puppet/desktop_list':
      source  => 'puppet:///contrib/desktop/desktop_list';
    # provide printing and other notification script daemon
    '/opt/share/puppet/notify.sh':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/notify.sh',
      require => File['/opt/share/puppet/desktop_list'];
    # provide share directory with icons and wallpapers
    '/opt/share/xsession':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///contrib/desktop/xsession',
      require => Class['common::puppet'];
    # enforce list of possible xsessions
    '/usr/share/xsessions':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///modules/desktop/xsession/xsessions'
  }

  # lightdm configuration
  # install lightdm as login manager with minimal bloat
  file {
    '/etc/lightdm/lightdm.conf':
      source  => 'puppet:///modules/desktop/xsession/lightdm/lightdm.conf';
    '/etc/lightdm/lightdm-gtk-greeter.conf':
        source  => 'puppet:///modules/desktop/xsession/lightdm/lightdm-gtk-greeter.conf';
    '/etc/X11/default-display-manager':
      source  => 'puppet:///modules/desktop/xsession/default-display-manager';
    # kill child processes on logout
    '/etc/lightdm/session-cleanup':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/lightdm/session-cleanup';
  }

  # use ocf logo on login screen
  file {
    '/usr/share/icons/hicolor/64x64/devices/ocf.png':
      backup  => false,
      source  => 'puppet:///contrib/desktop/ocf-color-64.png';
    '/usr/share/lightdm-gtk-greeter/greeter.ui':
      source  => 'puppet:///modules/desktop/xsession/lightdm/greeter.ui';
  }

  exec {
    'gtk-update-icon-cache /usr/share/icons/hicolor':
      subscribe  => File["/usr/share/icons/hicolor/64x64/devices/ocf.png"],
      refreshonly => true;
  }

  # polkit configuration
  # prevent privileged actions
  file {  '/usr/share/polkit-1/actions':
    ensure  => directory,
    recurse => true,
    purge   => true,
    force   => true,
    backup  => false,
    source  => 'puppet:///modules/desktop/xsession/polkit'
  }

  # lxde configuration
    # provide lxde wallpaper configuration
    if $::lsbdistcodename == 'wheezy' {
      file { '/etc/xdg/pcmanfm/LXDE/pcmanfm.conf':
        source  => 'puppet:///modules/desktop/xsession/lxde/LXDE.conf';
      }
    } else {
      file { '/usr/share/lxde/pcmanfm/LXDE.conf':
        source  => 'puppet:///modules/desktop/xsession/lxde/LXDE.conf';
    }
  }
  file {
    # provide lxterminal configuration to fix transparency bug
    '/usr/share/lxterminal/lxterminal.conf':
      source  => 'puppet:///modules/desktop/xsession/lxde/lxterminal.conf';
  }

  # lxde logout configuration
  file {
    # provide logout banner
    '/opt/share/xsession/logout-banner.png':
      backup  => false,
      source  => 'puppet:///contrib/desktop/logout-banner.png';
    # replace logout script configuration
    '/usr/bin/lxde-logout':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/lxde/lxde-logout'
  }

  # xfce configuration
  file {
    # enable kiosk mode (disables shutdown, etc.)
    '/etc/xdg/xfce4/kiosk':
      ensure => 'directory',
      source => 'puppet:///modules/desktop/xsession/xfce4/kiosk/',
      recurse => true,
      owner => 'root',
      group => 'root';
    # default config
    '/etc/xdg/xfce4/xfconf':
      ensure => 'directory',
      source => 'puppet:///modules/desktop/xsession/xfce4/xfconf/',
      recurse => true,
      owner => 'root',
      group => 'root';
  }

  file {
    # copy skel files
    '/etc/skel/.config':
      ensure => 'directory',
      source => 'puppet:///modules/desktop/skel/config/',
      recurse => true,
      owner => 'root',
      group => 'root';
  }

  # disable user switching and screen locking (prevent normal users
  # from executing the necessary binaries)
  file {
    '/usr/bin/lxlock':
      mode => '0744';
    '/usr/bin/xscreensaver-command':
      mode => '0744';
  }

  # font configuration
  file {
    # enable font auto-hinting
    '/etc/fonts/conf.d/10-autohint.conf':
      ensure => symlink,
      links  => manage,
      target => '/etc/fonts/conf.avail/10-autohint.conf';
    # enable font sub-pixel rendering
    '/etc/fonts/conf.d/10-sub-pixel-rgb.conf':
      ensure => symlink,
      links  => manage,
      target => '/etc/fonts/conf.avail/10-sub-pixel-rgb.conf'
  }

  # xscreensaver configuration
  package { 'xscreensaver': }
  file { '/etc/X11/app-defaults/XScreenSaver':
    mode    => '0755',
    backup  => false,
    source  => 'puppet:///modules/desktop/xsession/XScreenSaver',
    require => Package['xscreensaver']
  }

}
