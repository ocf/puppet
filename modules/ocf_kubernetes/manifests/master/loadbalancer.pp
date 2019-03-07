class ocf_kubernetes::master::loadbalancer {
  include ::haproxy

  include ocf::firewall::allow_web

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers_ipv4 = $kubernetes_worker_nodes.map |$worker| { ldap_attr($worker, 'ipHostNumber') }
  $haproxy_ssl = "/etc/ssl/private/${::fqdn}.pem"

  # At any given time, only one kubernetes master will hold
  # the first IP. The master holding the IP will handle all
  # HAProxy requests and send them into the cluster.
  #
  # TODO: If we expose TCP services, we may need to add more.
  #
  # IPv6 addresses have to be specified separately as they cannot be in the vrrp
  # packet together (keepalived 1.2.20+) so they need to be in a
  # virtual_ipaddress_excluded block instead.
  $virtual_addresses = [
    # Primary load balancer IP (v4)
    '169.229.226.79',
  ]
  $virtual_addresses_v6 = [
    # Primary load balancer IP (v6)
    '2607:f140:8801::1:79',
  ]
  $keepalived_secret = lookup('kubernetes::keepalived::secret')

  package { 'keepalived':; } ->
  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_kubernetes/master/loadbalancer/keepalived.conf.erb'),
    mode    => '0400',
  } ~>
  service { 'keepalived': }

  $vip = 'lb-kubernetes'

  class { 'ocf_kubernetes::master::loadbalancer::ssl':
    vip => $vip,
  }

  # Redirect from "cname.ocf.io" to "cname.ocf.berkeley.edu" for each cname.
  $cnames = ldap_attr($vip, 'dnsCname', true)
  $alias_redirects = flatten($cnames.map |$domain| {
    # When accessing domains from within the OCF subnet, going to the hostname
    # (e.g. typing "labmap/" into the web browser) should also redirect.
    prefix(['.ocf.io', ''], $domain).map |$fqdn| {
      {'redirect' => "prefix https://${domain}.ocf.berkeley.edu%[capture.req.uri] code 301 if { hdr(host) -i ${fqdn} }"}
    }
  })

  haproxy::frontend { 'kubernetes-frontend':
    mode    => 'http',
    bind    => {
      '0.0.0.0:80'  => [],
      '0.0.0.0:443' => ['ssl', 'crt', $haproxy_ssl],
    },
    options =>
    [{'default_backend' => 'kubernetes-backend'}]
    + $alias_redirects
    + [{'redirect'      => 'scheme https code 301 if !{ ssl_fc }'}],
    require => Class['ocf_kubernetes::master::loadbalancer::ssl'];
  } ->
  haproxy::frontend { 'kubernetes-proxy-frontend':
    # This is used for hosts that don't directly point to lb-kubernetes, but
    # are instead reverse proxied from another server (like puppet, www, irc)
    # This points to the same backend as other requests, but doesn't handle
    # alias redirects or TLS termination. In these cases, TLS is handled by the
    # upstream reverse proxy.
    mode    => 'http',
    bind    => {
      '0.0.0.0:4080' => [],
    },
    options => {'default_backend' => 'kubernetes-backend'},
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
    ports             => ['31234'],
    ipaddresses       => $kubernetes_workers_ipv4,
    server_names      => $kubernetes_worker_nodes;
  }

  # Reload HAProxy if any of the certs change
  Concat[$haproxy_ssl] ~> Haproxy::Service[haproxy]
}
