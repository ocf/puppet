class ocf_desktop::pulse {

  ocf::repackage {
    # PulseAudio without recommends
    'pulseaudio':
      recommends => false;
    # PulseAudio graphical interfaces
    [ 'paprefs', 'pavucontrol' ]:
      recommends => false,
      require    => Ocf::Repackage['pulseaudio'];
  }

  # ALSA ultilities and PulseAudio plugin
  package { [ 'alsa-utils', 'libasound2-plugins' ]: }

  # route ALSA sound through PulseAudio
  file { '/etc/asound.conf':
    source  => 'puppet:///modules/ocf_desktop/asound.conf',
    require => Package['libasound2-plugins'],
  }

  $pulse_sink = lookup('pulse_sink')
  if $pulse_sink {
    augeas { 'set-pulse-default-sink':
      incl => '/etc/pulse/default.pa',
      lens => 'Spacevars.simple_lns',
      changes => "set set-default-sink ${pulse_sink}",
    }
  }
}
