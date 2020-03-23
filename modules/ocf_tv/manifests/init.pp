class ocf_tv {
  include ocf_tv::pulse

  include ocf::packages::chrome
  include ocf::packages::firefox
  include ocf::packages::fonts
  include ocf_desktop::drivers
  include ocf_desktop::steam

  # Allow anyone on the ocf network to ssh into the TV.
  # External firewall already blocks outsiders.
  # Mostly so laptops can connect.
  include ocf::firewall::allow_ssh

  package {
    [
      'arandr',
      'ffmpeg',
      'feh',
      'i3',
      'lightdm',
      'mpc',
      'mpd',
      'python3-usb',
      'vlc',
      'x11vnc',
      'xinit',
    ]:;
  }

  group { 'autologin':
    system  => true;
  }

  user { 'ocftv':
    comment => 'TV NUC',
    home    => '/opt/tv',
    groups  => ['sys', 'audio', 'autologin'],
    shell   => '/bin/bash';
  }

  file {
    # Create home directory for ocftv user
    '/opt/tv':
      ensure  => directory,
      owner   => ocftv,
      group   => ocftv,
      require => User['ocftv'];

    '/etc/mpd.conf':
      source  => 'puppet:///modules/ocf_tv/mpd.conf',
      require => Package['mpd'];

    '/etc/lightdm/lightdm.conf':
      source  => 'puppet:///modules/ocf_tv/lightdm.conf',
      require => Package['lightdm'];

    '/etc/X11/xorg.conf':
      source => 'puppet:///modules/ocf_tv/X11/xorg.conf';

    '/opt/tv/.i3/config':
      mode   => '0644',
      owner  => ocftv,
      group  => ocftv,
      source => 'puppet:///modules/ocf_tv/i3/config';

    '/opt/share/background.png':
      mode   => '0644',
      owner  => ocftv,
      group  => ocftv,
      source => 'puppet:///modules/ocf_tv/X11/images/background.png';
  }

  ocf::systemd::service { 'x11vnc':
    source  => 'puppet:///modules/ocf_tv/x11vnc.service',
    require => [
      Package['x11vnc', 'lightdm'],
      User['ocftv'],
    ],
  }

}
