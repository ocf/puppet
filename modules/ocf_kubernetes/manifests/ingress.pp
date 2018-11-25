class ocf_kubernetes::ingress {

  $kubernetes_workers_ipv4 = lookup('kubernetes::workers_ipv4')
  $nginx_version = lookup('kubernetes::nginx_version')

  file {
    default:
      require =>  Package['kubeadm', 'kubectl'];

    '/etc/kubernetes/manifests/ingress':
      ensure => directory,
      mode   => '0700';

    '/etc/kubernetes/manifests/ingress/ingress-expose.yaml':
      content => template('ocf_kubernetes/ingress/ingress_expose.yaml.erb'),
      mode    => '0644';
  }

  # Add ingress-nginx to the cluster
  exec { 'init-ingress':
    command => "kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-${nginx_version}/deploy/mandatory.yaml",
    require => Package['kubectl'];
  } ->

  # Set up a NodePort service so all kubernetes workers
  # are running an instance of ingress-nginx.
  exec { 'expose-ingress':
    command     => 'kubectl apply -f /etc/kubernetes/manifests/ingress/ingress-expose.yaml',
    subscribe   => File['/etc/kubernetes/manifests/ingress/ingress-expose.yaml'],
    refreshonly => true,
    require     => Package['kubectl'];
  }
}
