class ocf_jenkins::jenkins_apt {
  apt::key { 'jenkins':
    id     => '62A9756BFD780C377CF24BA8FCEF32E745F2C3D5',
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
