class ocf_desktop::steam {
  package {
    # Preseeded installations are currently broken on Debian steam:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=772598
    #
    # We have an OCF-patched version (steam 1.0.0.49-1+ocf1) in our apt repo.
    #
    # This can be removed after we upgrade to stretch.
    'steam':
      responsefile => '/var/cache/debconf/steam.preseed',
      require      => File['/var/cache/debconf/steam.preseed'];

    'steam-installer':
      ensure => purged;
  }

  file {
    '/var/cache/debconf/steam.preseed':
      source => 'puppet:///modules/ocf_desktop/steam.preseed';
  }
}
