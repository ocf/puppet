class ocf_desktop::xsession {
  $staff_only = hiera('staff_only')

  require ocf_desktop::packages
  include ocf_desktop::xfce

  # Xsession configuration
  file {
    # custom Xsession script to populate desktop
    '/etc/X11/Xsession.d/95ocf':
      source  => 'puppet:///modules/ocf_desktop/xsession/Xsession',
      require => File['/opt/share/xsession'];
    # printing and other notification script daemon
    '/opt/share/puppet/notify':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/notify';
    # script for warning users when the lab is about to close
    '/opt/share/puppet/lab-close-notify':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/lab-close-notify';
    # script to tile multiple displays
    '/usr/local/bin/fix-displays':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/fix-displays';
    # script to fix audio on login
    '/usr/local/bin/fix-audio':
      mode    => '0755',
      source  => 'puppet:///modules/ocf_desktop/xsession/fix-audio';
    # list of possible xsessions
    '/usr/share/xsessions':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_desktop/xsession/xsessions',
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false;
    '/opt/share/xsession':
      ensure  => directory;
    '/opt/share/xsession/images':
      source  => 'puppet:///modules/ocf_desktop/xsession/images/',
      recurse => true,
      purge   => true;
    '/opt/share/xsession/icons':
      source  => 'puppet:///modules/ocf_desktop/xsession/icons/',
      recurse => true,
      purge   => true;
  }

  # wallpaper symlink
  if $::lsbdistcodename == 'jessie' {
    $wallpaper = $staff_only ? {
      true  => 'background-staff.png',
      false => 'background.png'
    }
  } else {
    $wallpaper = 'background.svg'
  }

  file { '/opt/share/wallpaper':
    ensure  => link,
    target  => "/opt/share/xsession/images/${wallpaper}",
    require => File['/opt/share/xsession/images'];
  }

  # lightdm configuration
  # install lightdm as login manager with minimal bloat
  file {
    '/etc/lightdm/lightdm.conf':
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/lightdm.conf';
    '/etc/lightdm/lightdm-gtk-greeter.conf':
      source  => 'puppet:///modules/ocf_desktop/xsession/lightdm/lightdm-gtk-greeter.conf';
    '/etc/X11/default-display-manager':
      content => "/usr/sbin/lightdm\n";
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

  # add pam_trimspaces to lightdm PAM stack
  augeas { 'lightdm-pam_trimspaces':
    context => '/files/etc/pam.d/lightdm',
    changes => [
      'ins #comment after #comment[1]',
      'set #comment[2] "Strip leading and trailing space from username"',
      'ins 01 after #comment[2]',
      'set 01/type auth',
      'set 01/control requisite',
      'set 01/module pam_trimspaces.so',
    ],
    onlyif  => 'match *[module = "pam_trimspaces.so"] size == 0';
  }

  # use ocf logo on login screen
  file {
    ['/usr/share/icons/Adwaita', '/usr/share/icons/Adwaita/256x256', '/usr/share/icons/Adwaita/256x256/status']:
      ensure => directory;
    '/usr/share/icons/Adwaita/256x256/status/avatar-default.png':
      ensure  => link,
      target  => '/opt/share/xsession/images/ocf-color-256.png',
      require => File['/opt/share/xsession/images'];
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

  if $::lsbdistcodename != 'jessie' {
    file {
      # Overwrite datetime file to add larger font on stretch
      '/etc/skel/.config/xfce4/panel/datetime-7.rc':
        source  => 'puppet:///modules/ocf_desktop/datetime-7-stretch.rc',
        require => File['/etc/skel/.config'];
    }
  }

  exec { 'xscreensaver-blanking-only':
    command => 'sed -i \'s/*mode:.*/*mode: blank/\' /etc/X11/app-defaults/XScreenSaver-nogl',
    unless  => 'grep \'mode: blank\' /etc/X11/app-defaults/XScreenSaver-nogl',
    require => Package['xscreensaver'];
  }

  # disable user switching and screen locking (prevent non-staff users from
  # executing the necessary binaries)
  file { '/usr/bin/xflock4':
    owner   => root,
    group   => ocfstaff,
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

  # Use GTK+ theme for Qt 4 apps
  file { '/etc/xdg/Trolltech.conf':
      source => 'puppet:///modules/ocf_desktop/xsession/Trolltech.conf';
  }
}
