class ocf_kubernetes::loadbalancer {
  include ::haproxy

  $kubernetes_workers_ipv4 = lookup('kubernetes::workers_ipv4')
  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')

  haproxy::frontend { 'kubernetes-frontend':
    mode    => 'http',
    bind    => {
      "${::ipaddress}:80"   => [],
      # TODO: Listen on 443 when we add TLS
      #"$::ipaddress:443"  =>  ['ssl', 'crt', '/path/to/cert.pem']
    },
    options => {
      'default_backend'  => 'kubernetes-backend',
      # TODO: enable once we add TLS
      #'redirect' =>  'scheme https code 301 if !{ ssl_fc }',
    };
  } ->
  haproxy::backend { 'kubernetes-backend':
    options => {
      option         => [
        'forwardfor'
      ],
      'mode'         => 'http',
      'balance'      => 'roundrobin',
      'http-request' => 'set-header X-Forwarded-Port %[dst_port]',
      # TODO: this does nothing until we add TLS
      'http-request' => 'add-header X-Forwarded-Proto https if { ssl_fc }',
    }
  } ->
  haproxy::balancermember { 'kubernetes-ingress-worker':
    listening_service => 'kubernetes-frontend',
    ports             => ['80'],
    ipaddresses       => $kubernetes_workers_ipv4,
    server_names      => $kubernetes_worker_nodes;
  }
}
