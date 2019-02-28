class ocf_kubernetes::master::persistent_volume {

  file {
    default:
      require => Package['kubectl'];

    '/etc/ocf-kubernetes/manifests/persistent-volume-nfs':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_kubernetes/persistent-volume-nfs',
      mode    => '0644',
      recurse => true;
  }

  # Add all of the required Persistent Volumes
  ocf_kubernetes::apply { 'init-persistent-volume':
    target    => '/etc/ocf-kubernetes/manifests/persistent-volume-nfs',
    subscribe => File['/etc/ocf-kubernetes/manifests/persistent-volume-nfs'],
  }
}
