class ocf::packages::chicago::apt {
  apt::key { 'obs':
    id     => 'D65A6C38FACB650F55438BB7FB2572B7B977DBCD',
    source => 'https://download.opensuse.org/repositories/home:bgstack15:Chicago95/Debian_Testing/Release.key';
  }

  apt::source {
    'obs':
      location => 'http://download.opensuse.org/repositories/home:/bgstack15:/Chicago95/Debian_Testing/',
      release  => '/',
      repos    => '',
      require  => Apt::Key['obs'];
  }
}
