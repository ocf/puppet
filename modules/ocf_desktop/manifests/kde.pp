class ocf_desktop::kde {
  package {
    ['kde-plasma-desktop', 'kwin-x11']:;
    ['okular', 'gwenview', 'konsole']:;
    ['kde-spectacle']:;

    # Utilities
    ['kcolorchooser']:;
  }

  # Remove some packages
  package {
    default:
      ensure => purged;
    'plasma-disks':;
    ['plasma-discover', 'packagekit', 'appstream']:;
    # avoid XFCE notifyd taking over KDE's notification daemon;
    # delete once XFCE is fully purged
    'xfce4-notifyd':;
  }

  # Use KDE apps
  alternatives { 'x-terminal-emulator':
    path    => '/usr/bin/konsole',
    require => Package['konsole'];
  }

}
