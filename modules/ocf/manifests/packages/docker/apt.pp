# Include Docker apt repo.
class ocf::packages::docker::apt {
  apt::key { 'docker':
    id     => '58118E89F3A912897C070ADBF76221572C52609D',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'docker':
    location    => 'http://apt.dockerproject.org/repo',
    release     => 'debian-jessie',
    repos       => 'main',
    include   => {
      src => false
    },
    require     => Apt::Key['docker'],
  }
}
