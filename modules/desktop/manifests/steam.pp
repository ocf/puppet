class desktop::steam {
  package {
    ['libc6:i386', 'libxinerama1:i386']:;

    # we use a custom-built package since otherwise we can't preseed license
    # acceptance (see https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=772598)
    'steam':
      provider     => dpkg,
      source       => '/opt/share/puppet/packages/steam_1.0.0.49-1+ocf1_i386.deb',

      # dpkg doesn't support responsefile, but this will be useful when we
      # switch back to apt provider
      # responsefile => '/var/cache/debconf/steam.preseed',

      require      => [Exec['accept-steam-license'], Package['libc6:i386', 'libxinerama1:i386']];

    'steam-installer':
      ensure => purged;
  }

  file {
    '/var/cache/debconf/steam.preseed':
      source => 'puppet:///modules/desktop/steam.preseed';
  }

  # we only need to do this because we use dpkg instead of apt
  exec { 'accept-steam-license':
    command     => 'debconf-set-selections /var/cache/debconf/steam.preseed',
    unless      => 'dpkg -l steam | grep ^ii',
    require     => File['/var/cache/debconf/steam.preseed'];
  }
}
