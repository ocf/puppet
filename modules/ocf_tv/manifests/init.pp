class ocf_tv {
  include ocf_tv::pulse

  include ocf::packages::chrome
  include ocf::packages::firefox
  include ocf_desktop::drivers
  include ocf_desktop::steam

  package {
    [
      'arandr',
      'ffmpeg',
      'feh',
      'i3',
      'nodm',
      'vlc',
      'x11vnc',
      'xinit',
    ]:;

    # fonts
    ['cm-super', 'fonts-croscore', 'fonts-crosextra-caladea', 'fonts-crosextra-carlito', 'fonts-inconsolata', 'fonts-linuxlibertine', 'fonts-unfonts-core', 'ttf-ancient-fonts']:;

    # nonfree packages
    ['ttf-mscorefonts-installer']:;
  }

  user { 'ocftv':
    comment => 'TV NUC',
    home    => '/opt/tv',
    groups  => ['sys', 'audio'],
    shell   => '/bin/bash';
  }

  file {
    # Create home directory for ocftv user
    '/opt/tv':
      ensure  => directory,
      owner   => ocftv,
      group   => ocftv,
      require => User['ocftv'];

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
      Package['x11vnc', 'nodm'],
      User['ocftv'],
    ],
  }
}
