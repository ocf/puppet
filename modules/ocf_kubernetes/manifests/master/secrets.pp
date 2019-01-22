class ocf_kubernetes::master::secrets {

  file {
    '/etc/ocf-kubernetes/secrets':
      ensure  => 'directory',
      source  => 'puppet:///kubernetes-secrets',
      require => Package['kubectl'],
      recurse => true,
      purge   => true,
      mode    => '0700';
  } ->

  # Apply the secrets directory
  ocf_kubernetes::apply { 'init-secrets':
    target    => '/etc/ocf-kubernetes/secrets',
  }
}
