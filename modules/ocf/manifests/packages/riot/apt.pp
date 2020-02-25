# Include Riot apt repo.
class ocf::packages::riot::apt {
  apt::key { 'riot':
    ensure => refreshed,
    id     =>  '12D4CD600C2240A9F4A82071D7B0B66941D01538',
    source => 'https://packages.riot.im/debian/riot-im-archive-keyring.asc',
  }

  apt::source { 'riot':
    architecture => 'amd64',
    location     => 'https://packages.riot.im/debian',
    release      => $::lsbdistcodename,
    repos        => 'main',
    require      => Apt::Key['riot'],
  }
}
