class ocf_tv {
  include ocf::packages::chrome

  package { ['i3', 'vlc', 'ffmpeg', 'nodm', 'xinit', 'iceweasel', 'pulseaudio', 'pavucontrol', 'arandr', 'flashplugin-nonfree', 'x11vnc']:; }

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

    '/etc/systemd/system/x11vnc.service':
      mode   => '0664',
      source => 'puppet:///modules/ocf_tv/x11vnc.service';
  }

  service {
    'x11vnc':
      ensure   => 'running',
      enable   => true,
      provider => systemd,
      require  => Package['x11vnc'];
  }

  exec {
    'x11vnc-update':
      command     => 'systemctl daemon-reload',
      refreshonly => true,
      require     => User['ocftv'],
      subscribe   => File['/etc/systemd/system/x11vnc.service'];
  }
}
