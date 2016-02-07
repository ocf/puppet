class ocf_tv {
  include ocf_desktop::chrome

  package { ['i3', 'vlc', 'ffmpeg', 'nodm', 'xinit', 'iceweasel', 'pulseaudio', 'pavucontrol', 'arandr', 'flashplugin-nonfree']:; }

  user { 'ocftv':
    comment => 'TV NUC',
    home    => '/opt/tv',
    groups  => ['sys', 'audio'],
    shell   => '/bin/bash';
  }

  file {
    '/etc/X11/xorg.conf':
      source => 'puppet:///modules/ocf_tv/X11/xorg.conf';
  }
}
