class ocf::desktop::pulse {

  package {
    # PulseAudio itself
    [ 'pulseaudio' ]:;
    # PulseAudio graphical interfaces
    [ 'paprefs', 'pavucontrol', 'pavumeter' ]:
  }

  # route ALSA sound through PulseAudio
  file { '/etc/asound.conf':
    source  => 'puppet:///modules/ocf/desktop/asound.conf',
    require => Package['pulseaudio']
  }

}
