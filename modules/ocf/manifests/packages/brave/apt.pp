# Include Brave apt repo.
class ocf::packages::brave::apt {
  apt::key { 'brave':
    ensure => refreshed,
    id     =>  'D8BAD4DE7EE17AF52A834B2D0BB75829C2D4E821',
    source => 'https://brave-browser-apt-release.s3.brave.com/brave-core.asc',
  }

  apt::source { 'brave':
    architecture => 'amd64',
    location     => 'https://brave-browser-apt-release.s3.brave.com',
    release      => $::lsbdistcodename,
    repos        => 'main',
    require      => Apt::Key['brave'],
  }
}
