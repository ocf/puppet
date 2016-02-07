class ocf_tv {
  include ocf::packages::chrome

  package { ['i3', 'vlc', 'ffmpeg', 'nodm', 'xinit', 'iceweasel', 'pulseaudio', 'pavucontrol', 'arandr', 'flashplugin-nonfree']:; }

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
  }
}
