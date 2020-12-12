# Include Element apt repo.
class ocf::packages::element::apt {
  apt::key { 'element':
    ensure => refreshed,
    id     => '12D4CD600C2240A9F4A82071D7B0B66941D01538',
    source => 'https://packages.riot.im/debian/riot-im-archive-keyring.asc',
  }

  apt::source { 'element':
    architecture => 'amd64',
    location     => 'https://packages.riot.im/debian',
    release      => $::lsbdistcodename,
    repos        => 'main',
    require      => Apt::Key['element'],
  }
}
