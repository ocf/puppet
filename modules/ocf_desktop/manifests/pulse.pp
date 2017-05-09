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

  $pulse_sink = lookup({'name' => 'pulse_sink', 'default_value' => nil})
  if $pulse_sink {
    exec { 'set-pulse-default-sink':
      command => "sed -i 's/#set-default-sink output/set-default-sink ${pulse_sink}/' /etc/pulse/default.pa",
      unless => 'grep ^set-default-sink /etc/pulse/default.pa > /dev/null',
    }
  }
}
