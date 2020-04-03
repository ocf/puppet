class ocf_kubernetes::logging {

  file { '/etc/ocf-kubernetes/manifests/logging':
    ensure  => directory,
    source  => 'puppet:///modules/ocf_kubernetes/logging',
    mode    => '0644',
    purge   => true,
    recurse => true;
  }

  ocf_kubernetes::apply { 'init-logging':
    target    => '/etc/ocf-kubernetes/manifests/logging',
    subscribe => File['/etc/ocf-kubernetes/manifests/logging'],
  }
}
