class ocf_tv::pulse {
  include ocf::packages::pulse;

  # Make pulse listen on localhost so desktops can SSH tunnel to it
  $tcp_module = 'load-module module-native-protocol-tcp listen=127.0.0.1 port=4713 auth-anonymous=1'
  exec { 'enable-pulse-tcp-listen':
    command => "echo '${tcp_module}' >> /etc/pulse/default.pa",
    unless  => "grep -q '^${tcp_module}$' /etc/pulse/default.pa",
    require => Package['pulseaudio'],
  }
}
