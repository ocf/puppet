class ocf_desktop::xsession ($staff = false) {
  require packages
  include xfce

  # Xsession configuration
  file {
    # custom Xsession script to populate desktop
    '/etc/X11/Xsession.d/95ocf':
      source  => 'puppet:///modules/ocf_desktop/xsession/Xsession',
      require => File['/opt/share/xsession'];
    # printing and other notification script daemon
    '/opt/share/puppet/notify.sh':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/notify.sh';
    # script to tile multiple displays
    '/usr/local/bin/fix-displays':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/fix-displays';
    # script to fix audio on login
    '/usr/local/bin/fix-audio':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/fix-audio';
    # share directory with icons and wallpapers
    '/opt/share/xsession':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///contrib/desktop/xsession',
      require => Class['ocf::puppet'];
    # list of possible xsessions
    '/usr/share/xsessions':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
      source  => 'puppet:///modules/ocf_desktop/xsession/xsessions'
  }

  # wallpaper symlink
  $wallpaper = $staff ? {
    true  => 'background-staff',
    false => 'background'
  }

  file { '/opt/share/wallpaper':
    ensure  => link,
    links   => manage,
    target  => "/opt/share/xsession/${wallpaper}",
    require => File['/opt/share/xsession'];
  }

  # lightdm configuration
  # install lightdm as login manager with minimal bloat
  file {
    '/etc/lightdm/lightdm.conf':
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/lightdm.conf';
    '/etc/lightdm/lightdm-gtk-greeter.conf':
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/lightdm-gtk-greeter.conf';
    '/etc/X11/default-display-manager':
      source  => 'puppet:///modules/ocf_desktop/xsession/default-display-manager';
    '/etc/lightdm/session-setup':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/session-setup';
    # kill child processes on logout
    '/etc/lightdm/session-cleanup':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/session-cleanup';
  }

  # overwrite greeter strings with OCF ones
  package {'gettext':;}

  $po = $::staff_only ? {
    true    => 'lightdm-gtk-greeter-staff.po',
    default => 'lightdm-gtk-greeter.po',
  }

  file { "/opt/share/xsession/${po}":
      source  => "puppet:///modules/ocf_desktop/xsession/lightdm/${po}";
  }

  exec { 'lightdm-greeter-compile-po':
      command     => "msgfmt -o /usr/share/locale/en_US/LC_MESSAGES/lightdm-gtk-greeter.mo \
                      /opt/share/xsession/${po}",
      subscribe   => File["/opt/share/xsession/${po}"],
      refreshonly => true,
      require     => Package['lightdm-gtk-greeter', 'gettext'];
  }

  # use ocf logo on login screen
  file {
    ['/usr/share/icons/Adwaita', '/usr/share/icons/Adwaita/256x256', '/usr/share/icons/Adwaita/256x256/status']:
      ensure => directory;
    '/usr/share/icons/Adwaita/256x256/status/avatar-default.png':
      source => 'puppet:///contrib/desktop/ocf-color-256.png';
  }

  # polkit configuration
  file {
    # restrict polkit actions
    '/etc/polkit-1/localauthority/90-mandatory.d/99-ocf.pkla':
      source => 'puppet:///modules/ocf_desktop/xsession/polkit/99-ocf.pkla',
    ;
    # use ocfroot group for polkit admin auth
    '/etc/polkit-1/localauthority.conf.d/99-ocf.conf':
      source => 'puppet:///modules/ocf_desktop/xsession/polkit/99-ocf.conf',
    ;
  }

  file {
    # copy skel files
    '/etc/skel/.config':
      ensure => directory,
      source => 'puppet:///modules/ocf_desktop/skel/config',
      recurse => true;
  }

  exec { 'xscreensaver-blanking-only':
    command => 'sed -i \'s/*mode:.*/*mode: blank/\' /etc/X11/app-defaults/XScreenSaver-nogl',
    unless  => 'grep \'mode: blank\' /etc/X11/app-defaults/XScreenSaver-nogl',
    require => Package['xscreensaver'];
  }

  # disable user switching and screen locking (prevent non-staff users from
  # executing the necessary binaries)
  file {
    '/usr/bin/xflock4':
      owner   => root,
      group   => 1001, # ocfstaff
      mode    => '0754',
      require => Package['xscreensaver'];
  }

  # improve font rendering
  file {
    # disable autohinter
    '/etc/fonts/conf.d/10-autohint.conf':
      ensure => absent;
    # enable subpixel rendering
    '/etc/fonts/conf.d/10-sub-pixel-rgb.conf':
      ensure => symlink,
      links  => manage,
      target => '../conf.avail/10-sub-pixel-rgb.conf';
    # enable LCD filter
    '/etc/fonts/conf.d/11-lcdfilter-default.conf':
      ensure => symlink,
      links  => manage,
      target => '../conf.avail/11-lcdfilter-default.conf';
    # enable hinting and anti-aliasing
    '/etc/fonts/local.conf':
      source => 'puppet:///modules/ocf_desktop/xsession/fonts.conf';
  }

  # auto logout users
  package {
    ['xautolock',
    'gir1.2-notify-0.7']:;
  }

  file { '/usr/local/bin/auto-lock':
      mode   => '0755',
      source => 'puppet:///modules/ocf_desktop/xsession/auto-lock';
  }

  # disable xscreensaver new login button
  file { '/etc/X11/Xresources/XScreenSaver':
      content => "XScreenSaver*newLoginCommand:\n"
  }
}
