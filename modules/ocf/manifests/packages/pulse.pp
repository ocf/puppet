class ocf::packages::pulse {
  ocf::repackage {
    # PulseAudio without recommends
    'pulseaudio':
      recommends => false;
    # PulseAudio graphical interfaces
    [ 'pavucontrol' ]:
      recommends => false,
      require    => Ocf::Repackage['pulseaudio'];
  }

  # ALSA utilities and PulseAudio plugin
  package { [ 'alsa-utils', 'libasound2-plugins' ]: }

  # route ALSA sound through PulseAudio
  file { '/etc/asound.conf':
    source  => 'puppet:///modules/ocf_desktop/asound.conf',
    require => Package['libasound2-plugins'],
  }
}
