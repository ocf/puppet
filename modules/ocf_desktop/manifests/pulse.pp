class ocf_desktop::pulse {

  ocf::repackage {
    # PulseAudio without recommends
    'pulseaudio':;
    # PulseAudio graphical interfaces
    [ 'paprefs', 'pavucontrol' ]:
      require    => Ocf::Repackage['pulseaudio'];
  }

  # ALSA ultilities and PulseAudio plugin
  package { [ 'alsa-utils', 'libasound2-plugins' ]: }

  # route ALSA sound through PulseAudio
  file { '/etc/asound.conf':
    source  => 'puppet:///modules/ocf_desktop/asound.conf',
    require => Package['libasound2-plugins'],
  }

}
