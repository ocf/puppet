class ocf_kubernetes::master::ingress::nginx {

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }

  file {
    default:
      require =>  Package['kubeadm', 'kubectl'];

    '/etc/ocf-kubernetes/manifests/ingress':
      ensure => directory,
      mode   => '0700';

    '/etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml':
      content => template('ocf_kubernetes/ingress/ingress_expose.yaml.erb'),
      mode    => '0644';

    '/etc/ocf-kubernetes/manifests/ingress/ingress-deploy.yaml':
      content => 'puppet:///modules/ocf_kubernetes/ingress_deploy.yaml',
      mode    => '0644';
  }

  # Add ingress-nginx to the cluster
  ocf_kubernetes::apply { 'ingress-init':
    target    => '/etc/ocf-kubernetes/manifests/ingress/ingress-deploy.yaml',
  } ->

  # Set up a NodePort service so all kubernetes workers
  # are running an instance of ingress-nginx.
  ocf_kubernetes::apply { 'expose-ingress':
    target    => '/etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml',
    subscribe => File['/etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml'],
  }
}
