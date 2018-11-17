class ocf::packages::docker_kubernetes {
  class { 'ocf::packages::docker::apt':
    stage => first,
  }

  $docker_kube_version = lookup('kubernetes::docker_version')

  # Kubernetes is specific about which versions of docker it will
  # work reliably with.
  package {
    'docker-ce':
      ensure => $docker_kube_version;
  } ->
  apt::pin { 'docker-ce':
    ensure   => present,
    packages => ['docker-ce'],
    priority => 1001,
    version  => $docker_kube_version;
  }
}
