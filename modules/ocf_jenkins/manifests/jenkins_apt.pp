class ocf_jenkins::jenkins_apt {
  apt::key { 'jenkins':
    id     => '150FDE3F7787E7D11EF4E12A9B7D32F2D50582E6',
    source => 'http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key';
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
