# Include Atom apt repo.
class ocf::packages::atom::apt {
  apt::key { 'atom':
    id     => '0A0FAB860D48560332EFB581B75442BBDE9E3B09',
    source => 'https://packagecloud.io/AtomEditor/atom/gpgkey';
  }

  apt::source {
    'packagecloud-atom':
      location => '[arch=amd64] https://packagecloud.io/AtomEditor/atom/any/',
      release  => 'any',
      repos    => 'main',
      require  => Apt::Key['atom'];
  }
}
