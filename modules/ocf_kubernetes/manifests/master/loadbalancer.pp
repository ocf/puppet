class ocf_kubernetes::master::loadbalancer {
  include ::haproxy

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }

  class { 'ocf_kubernetes::master::loadbalancer::ssl':
    server_name => $::hostname,
  } ->
  haproxy::frontend { 'kubernetes-frontend':
    mode    => 'http',
    bind    => {
      '0.0.0.0:80'  => [],
      '0.0.0.0:443' => ['ssl', 'crt-list', '/etc/ssl/ocf-certs.txt'],
    },
    options => {
      'default_backend' => 'kubernetes-backend',
      'redirect'        => 'scheme https code 301 if !{ ssl_fc }',
    };
  } ->
  haproxy::backend { 'kubernetes-backend':
    options => {
      option         => [
        'forwardfor',
      ],
      'mode'         => 'http',
      'balance'      => 'source',
      'hash-type'    => 'consistent',
      'http-request' => 'add-header X-Forwarded-Proto https if { ssl_fc }',
    }
  } ->
  haproxy::balancermember { 'kubernetes-ingress-worker':
    listening_service => 'kubernetes-frontend',
    ports             => ['80'],
    ipaddresses       => $kubernetes_workers_ipv4,
    server_names      => $kubernetes_worker_nodes;
  }

  File['/etc/ssl/ocf-certs.txt'] ~> Haproxy::Service[haproxy]
}
