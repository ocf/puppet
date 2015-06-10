class ocf_jenkins {
  include ocf_ssl
  include ocf::extrapackages

  class { 'ocf_jenkins::jenkins_apt':
    stage => first;
  }

  include proxy

  package { 'jenkins':; }
  service { 'jenkins':
    require => Package['jenkins'];
  }

  augeas { '/etc/default/jenkins':
    context => '/files/etc/default/jenkins',
    changes => [
      'set JAVA_ARGS \'"-Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Xmx1024m"\'',
    ],
    require => Package['jenkins'],
    notify  => Service['jenkins'];
  }
}
