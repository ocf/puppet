class ocf_kubernetes::master::argocd {

  file {
    default:
      require => Package['kubectl'];

    '/etc/ocf-kubernetes/manifests/argocd':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_kubernetes/argocd',
      mode    => '0644',
      recurse => true;
  }

  # Add all of the required Persistent Volumes
  ocf_kubernetes::applyk { 'argocd':
    target    => '/etc/ocf-kubernetes/manifests/argocd',
    subscribe => File['/etc/ocf-kubernetes/manifests/argocd'],
  }
}
