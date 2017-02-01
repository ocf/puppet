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
      'debian-unstable':
        location => 'http://mirrors/debian/',
        release  => 'unstable',
        repos    => 'main',
        include  => {
          src => true
        },
    }

    # Pin ONLY unstable to 150 so that it isn't preferred over regular repos or
    # even backports. Previously, putting pin into apt::source above pinned the
    # stable repo to the same value, which was bad.
    apt::pin {
      'debian-unstable':
        priority => 150,
        release  => 'unstable';
    }
  }
}
