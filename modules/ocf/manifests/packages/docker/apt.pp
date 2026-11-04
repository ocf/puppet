# Include Docker apt repo.
class ocf::packages::docker::apt {
  apt::keyring { 'docker.asc':
    source => 'https://download.docker.com/linux/debian/gpg',
  }

  apt::source { 'docker':
    location => '[arch=amd64] https://download.docker.com/linux/debian',
    release  => $facts['os']['distro']['codename'],
    repos    => 'stable',
    keyring  => '/etc/apt/keyrings/docker.asc',
    require  => Apt::Keyring['docker.asc'],
  }
}
