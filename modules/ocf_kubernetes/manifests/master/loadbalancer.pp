class ocf_kubernetes::master::loadbalancer {
  include ocf::ssl::default
  include ::haproxy

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }
  $haproxy_ssl = "/etc/ssl/private/${::fqdn}.pem"

  haproxy::frontend { 'kubernetes-frontend':
    mode    => 'http',
    bind    => {
      '0.0.0.0:80'  => [],
      '0.0.0.0:443' => ['ssl', 'crt', $haproxy_ssl],
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

  # Reload HAProxy if any of the certs change
  Concat[$haproxy_ssl] ~> Haproxy::Service[haproxy]
}
