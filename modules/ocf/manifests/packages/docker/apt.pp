# Include Docker apt repo.
class ocf::packages::docker::apt {
  apt::key { 'docker':
    id      => '9DC858229FC7DD38854AE2D88D81803C0EBFCD88',
    source  => 'https://download.docker.com/linux/debian/gpg',
  }

  apt::source { 'docker':
    location => '[arch=amd64] https://download.docker.com/linux/debian',
    release  => $facts['os']['distro']['codename'],
    repos    => 'stable',
    require  => Apt::Key['docker'],
  }
}
