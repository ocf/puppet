class ocf::packages::firefox::apt {

  if $::lsbdistcodename == 'jessie' {
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
  } else {
    # TODO: switch to mozilla.debian.net once they support stretch.
    apt::source {
      'debian-experimental':
        location => 'http://mirrors/debian/',
        release  => 'experimental',
        repos    => 'main',
        include  => {
          src => true
        },
    }
  }
}
