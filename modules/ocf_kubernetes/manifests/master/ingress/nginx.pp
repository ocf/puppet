class ocf_kubernetes::master::ingress::nginx {

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }
  $nginx_version = lookup('kubernetes::nginx_version')
  $ingress_nginx_url = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/nginx-${nginx_version}/deploy/mandatory.yaml"

  file {
    default:
      require =>  Package['kubeadm', 'kubectl'];

    '/etc/ocf-kubernetes/manifests':
      ensure => directory,
      mode   => '0700';

    '/etc/ocf-kubernetes/manifests/ingress':
      ensure => directory,
      mode   => '0700';

    '/etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml':
      content => template('ocf_kubernetes/ingress/ingress_expose.yaml.erb'),
      mode    => '0644';
  }

  # Add ingress-nginx to the cluster
  exec { 'init-ingress':
    environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    command     => "kubectl apply -f ${ingress_nginx_url}",
    require     => Package['kubectl'];
  } ->

  # Set up a NodePort service so all kubernetes workers
  # are running an instance of ingress-nginx.
  exec { 'expose-ingress':
    environment => ['KUBECONFIG=/etc/kubernetes/admin.conf'],
    command     => 'kubectl apply -f /etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml',
    subscribe   => File['/etc/ocf-kubernetes/manifests/ingress/ingress-expose.yaml'],
    require     => Package['kubectl'];
  }
}
