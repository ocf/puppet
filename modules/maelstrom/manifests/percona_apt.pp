class maelstrom::percona_apt {
  apt::key { 'percona':
    key        => '1C4CBDCDCD2EFD2A',
    key_server => 'keys.gnupg.net';
  }

  apt::source { 'percona':
    location => 'http://repo.percona.com/apt',
    release  => $::lsbdistcodename,
    repos    => 'main',
    require  => Apt::Key['percona'];
  }
}
