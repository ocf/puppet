class ocf_jenkins::jenkins_apt {
  apt::key { 'jenkins':
    id     => '63667EE74BBA1F0A08A698725BA31D57EF5975CA',
    source => 'https://pkg.jenkins.io/debian/jenkins.io-2023.key';
  }

  apt::source { 'jenkins':
    location => 'http://pkg.jenkins-ci.org/debian',
    release  => 'binary/',
    repos    => '',
    include  => {
      src => false
    };
  }
}
