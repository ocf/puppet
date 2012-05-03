class ocf::desktop::pulse {

  # PulseAudio without recommends
  ocf::repackage { 'pulseaudio':
    recommends => false
  }

  # PulseAudio ALSA plugin
  package { 'libasound2-plugins':
    require => Ocf::Repackage['pulseaudio']
  }

  # PulseAudio graphical interfaces
  ocf::repackage { [ 'paprefs', 'pavucontrol' ]:
    recommends => false,
    require    => Ocf::Repackage['pulseaudio']
  }

  # route ALSA sound through PulseAudio
  file { '/etc/asound.conf':
    source  => 'puppet:///modules/ocf/desktop/asound.conf',
    require => Package['libasound2-plugins']
  }

}
