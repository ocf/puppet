# Proxy HTTPS requests to the Kubernetes ingress controller and redirect
# aliases to their canonical URLs
define ocf_kubernetes::master::loadbalancer::http_vhost(
  $server_name,
  $server_aliases,
) {
  ocf::nginx_proxy { $title:
    server_name      => $server_name,
    server_aliases   => $server_aliases,
    proxy            => 'http://kubernetes',
    proxy_set_header => [
      'Upgrade $http_upgrade',
      'Connection $connection_upgrade',
    ],
    ssl              => true,
  }
}
