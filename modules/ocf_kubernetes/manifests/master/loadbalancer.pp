class ocf_kubernetes::master::loadbalancer {
  include ocf::ssl::default
  include ::haproxy

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }

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

  # The primary domain for the SANS cert, which is the name of the pem file.
  $primary_domain = '.ocf.berkeley.edu'

  # These domains are also included in the *.ocf.berkeley.edu.pem file.
  # We'll need to list them all in the ocf-certs.txt file so HAProxy
  # knows which domains each cert covers.
  $alt_domains = ['.ocf.io']

  $cnames = ldap_attr($::hostname, 'dnsCname', true)

  file { '/etc/ssl/ocf-certs.txt':
    mode    => '0400',
    owner   => 'haproxy',
    group   => 'haproxy',
    content => template('ocf_kubernetes/master/loadbalancer/ssl/ocf-certs.txt.erb'),
    notify  => Haproxy::Service[haproxy],
  }
}
