class ocf_jenkins::jenkins_apt {
  apt::keyring { 'jenkins.asc':
    source => 'https://pkg.jenkins.io/debian/jenkins.io-2023.key';
  }

  apt::source { 'jenkins':
    location => 'http://pkg.jenkins-ci.org/debian',
    release  => 'binary/',
    repos    => '',
    keyring  => '/etc/apt/keyrings/jenkins.asc',
    require  => Apt::Keyring['jenkins.asc'],
    include  => {
      src => false
    };
  }
}
