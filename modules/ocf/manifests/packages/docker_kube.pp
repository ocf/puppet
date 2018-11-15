class ocf::packages::docker_kube {
  class { 'ocf::packages::docker::apt':
    stage => first,
  }

  package {
    'docker-ce':
      ensure => lookup('kubernetes::docker_version');
  }
}
