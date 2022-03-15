class ocf_desktop::kde {
  package {
    ['kde-plasma-desktop', 'kwin-x11', 'okular']:
  }

  # Remove some packages
  package {
    default:
      ensure => purged;
    'plasma-disks':;
    ['plasma-discover', 'packagekit', 'appstream']:;
  }

  # Use KDE apps
  alternatives { 'x-terminal-emulator':
    path => '/usr/bin/konsole';
  }
}
