class ocf_kubernetes::master::persistent_volume {

  file {
    default:
      require => Package['kubectl'];

    '/etc/ocf-kubernetes/manifests/persistent-volume-nfs.yaml':
      source => 'puppet:///modules/ocf_kubernetes/persistent-volume-nfs.yaml',
      mode   => '0644';
  }

  # Add all of the required Persistent Volumes
  ocf_kubernetes::apply { 'init-persistent-volume':
    target    => '/etc/ocf-kubernetes/manifests/persistent-volume-nfs.yaml',
    subscribe => File['/etc/ocf-kubernetes/manifests/persistent-volume-nfs.yaml'],
  }
}
