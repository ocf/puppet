class ocf_desktop::steam {
  include ocf::apt::i386

  package {
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
