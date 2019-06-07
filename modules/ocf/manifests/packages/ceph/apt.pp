# Include Ceph apt repo.
class ocf::packages::ceph::apt {
  apt::key { 'ceph':
    id      => '08B73419AC32B4E966C1A330E84AC2C0460F3994',
    source  => 'https://download.ceph.com/keys/release.asc',
    require => Package['apt-transport-https'],
  }

  apt::source { 'ceph':
    location => 'https://download.ceph.com/debian-luminous',
    release  => $::lsbdistcodename,
    repos    => 'main',
    require  => [Apt::Key['ceph'], Package['apt-transport-https']],
  }
}
