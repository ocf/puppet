class ocf_tv::pulse {
  include ocf::packages::pulse;

  # pulseaudio as a systemd service fixes a number of
  # problems with the daemon not starting properly
  # or starting with the wrong environment
  ocf::systemd::service { 'pulseaudio':
    source => 'puppet:///modules/ocf_tv/pulseaudio.service',
    require => [
      Package['pulseaudio'],
      User['ocftv'],
    ],
  }

  # Make pulse listen on localhost so desktops can SSH tunnel to it
  $tcp_module = 'load-module module-native-protocol-tcp listen=127.0.0.1 port=4713 auth-anonymous=1'
  exec { 'enable-pulse-tcp-listen':
    command => "echo '${tcp_module}' >> /etc/pulse/default.pa",
    unless  => "grep -q '^${tcp_module}$' /etc/pulse/default.pa",
    require => Package['pulseaudio'],
    notify  => Service['pulseaudio'],
  }

  # the timer-based scheduler performs worse for some reason for remote audio
  # on our network, so we disable it in favor of the interrupt-based one.
  # "load-module module-udev-detect" is generally line 47 in default.pa
  exec { 'change-pulse-scheduler':
    command => "sed -i 's/module-udev-detect$/module-udev-detect tsched=0/' /etc/pulse/default.pa",
    unless  => "grep -q 'tsched=0' /etc/pulse/default.pa",
    require => Package['pulseaudio'],
    notify  => Service['pulseaudio'],
  }

  # configure the default server manually so we don't have to run
  # pax11publish -e -S 127.0.0.1 every time Xorg restarts
  $default_server = 'default-server = 127.0.0.1'
  exec { 'set-default-server':
    command => "echo '${default_server}' >> /etc/pulse/client.conf",
    unless  => "grep -q '^${default_server}$' /etc/pulse/client.conf",
    require => Package['pulseaudio'],
    notify  => Service['pulseaudio'],
  }
}
