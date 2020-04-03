class ocf_kubernetes::logging {

  file { '/etc/ocf-kubernetes/manifests/logging.yaml':
    ensure => present,
    source => 'puppet:///modules/ocf_kubernetes/logging.yaml',
    mode   => '0644';
  }

  ocf_kubernetes::apply { 'init-logging':
    target    => '/etc/ocf-kubernetes/manifests/logging.yaml',
    subscribe => File['/etc/ocf-kubernetes/manifests/logging.yaml'],
  }
}
