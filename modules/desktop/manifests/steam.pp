class desktop::steam {
  package {
    # Preseeded installations are currently broken on Debian steam:
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=772598
    #
    # We have an OCF-patched version (steam 1.0.0.49-1+ocf1) in our apt repo.
    'steam':
      responsefile => '/var/cache/debconf/steam.preseed';

    'steam-installer':
      ensure => purged;
  }

  file {
    '/var/cache/debconf/steam.preseed':
      source => 'puppet:///modules/desktop/steam.preseed';
  }
}
