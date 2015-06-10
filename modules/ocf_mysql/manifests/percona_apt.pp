class ocf_mysql::percona_apt {
  apt::key { 'percona':
    id     => '430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A',
    server => 'keys.gnupg.net';
  }

  apt::source { 'percona':
    location => 'http://repo.percona.com/apt',
    release  => $::lsbdistcodename,
    repos    => 'main',
    require  => Apt::Key['percona'];
  }
}
