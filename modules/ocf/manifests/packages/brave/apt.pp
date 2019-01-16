# Include Brave apt repo.
class ocf::packages::brave::apt {
  apt::key { 'brave':
    id     => 'D8BAD4DE7EE17AF52A834B2D0BB75829C2D4E821',
    server => 'pgp.ocf.berkeley.edu',
  }

  apt::source { 'brave':
    architecture => 'amd64',
    location     => 'https://brave-browser-apt-release.s3.brave.com',
    release      => $::lsbdistcodename,
    repos        => 'main',
    require      => Apt::Key['brave'],
  }
}
