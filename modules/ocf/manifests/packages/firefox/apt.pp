class ocf::packages::firefox::apt {
  package { 'pkg-mozilla-archive-keyring':; }

  apt::source {
    'mozilla':
      location => 'http://mozilla.debian.net/',
      release  => "${::lsbdistcodename}-backports",
      repos    => 'firefox-release',
      include  => {
        src => true
      },
      require  => Package['pkg-mozilla-archive-keyring'],
  }
}
