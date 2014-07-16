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
    # provide script to tile multiple displays
    '/usr/local/bin/fix-displays':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/fix-displays';
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
    '/etc/lightdm/session-setup':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/lightdm/session-setup';
    # kill child processes on logout
    '/etc/lightdm/session-cleanup':
      mode    => '0755',
      source  => 'puppet:///modules/desktop/xsession/lightdm/session-cleanup';
  }

  # use ocf logo on login screen
  file { '/usr/share/icons/hicolor/64x64/devices/ocf.png':
    backup  => false,
    source  => 'puppet:///contrib/desktop/ocf-color-64.png',
  }

  exec {
    'gtk-update-icon-cache /usr/share/icons/hicolor':
      subscribe  => File["/usr/share/icons/hicolor/64x64/devices/ocf.png"],
      refreshonly => true;
  }

  # polkit configuration
  file {
    # restrict polkit actions
    '/etc/polkit-1/localauthority/90-mandatory.d/99-ocf.pkla':
      source => 'puppet:///modules/desktop/xsession/polkit/99-ocf.pkla',
    ;
    # use ocfroot group for polkit admin auth
    '/etc/polkit-1/localauthority.conf.d/99-ocf.conf':
      source => 'puppet:///modules/desktop/xsession/polkit/99-ocf.conf',
    ;
  }

  # lxde configuration
  file {
    # provide lxde wallpaper configuration
    '/etc/xdg/pcmanfm/LXDE/pcmanfm.conf':
      source  => 'puppet:///modules/desktop/xsession/lxde/LXDE.conf',
    ;
    # provide lxterminal configuration to fix transparency bug
    '/usr/share/lxterminal/lxterminal.conf':
      source  => 'puppet:///modules/desktop/xsession/lxde/lxterminal.conf',
    ;
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

  # disable user switching and screen locking (prevent non-staff users from
  # executing the necessary binaries)
  file {
    ['/usr/bin/lxlock', '/usr/bin/xflock4']:
      owner => root,
      group => 1002, # approve
      mode => '0754';
  }

  # improve font rendering
  file {
    # disable autohinter
    '/etc/fonts/conf.d/10-autohint.conf':
      ensure => absent,
    ;
    # enable subpixel rendering
    '/etc/fonts/conf.d/10-sub-pixel-rgb.conf':
      ensure => symlink,
      links  => manage,
      target => '../conf.avail/10-sub-pixel-rgb.conf',
    ;
    # enable LCD filter
    '/etc/fonts/conf.d/11-lcdfilter-default.conf':
      ensure => symlink,
      links  => manage,
      target => '../conf.avail/11-lcdfilter-default.conf',
    ;
    # enable hinting and anti-aliasing
    '/etc/fonts/local.conf':
      source => 'puppet:///modules/desktop/xsession/fonts.conf',
    ;
  }

}
