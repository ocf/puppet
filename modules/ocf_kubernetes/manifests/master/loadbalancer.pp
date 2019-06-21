class ocf_kubernetes::master::loadbalancer {
  include ocf::firewall::allow_web

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $death_ipv4 = lookup('death_ipv4')
  $death_ipv6 = lookup('death_ipv6')

  # Allow death to talk to Kubernetes (ocfweb)
  firewall_multi {
    '101 accept from death (IPv4)':
      chain  => 'PUPPET-INPUT',
      source => $death_ipv4,
      proto  => 'tcp',
      dport  => [4080],
      action => 'accept';

    '101 accept from death (IPv6)':
      chain    => 'PUPPET-INPUT',
      source   => $death_ipv6,
      proto    => 'tcp',
      dport    => [4080],
      action   => 'accept',
      provider => 'ip6tables';
  }

  # At any given time, only one kubernetes master will hold
  # the first IP. The master holding the IP will handle all
  # nginx requests and send them into the cluster.
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

  $upstream_workers = Hash.new($kubernetes_worker_nodes.map |String $worker| {
    [
      "${worker}:31234",
      {
        server => $worker,
        port   => 31234,
      },
    ]
  })
  nginx::resource::upstream {
    'kubernetes':
      members => $upstream_workers
  }

  # websocket support
  # see https://www.nginx.com/blog/websocket-nginx/
  nginx::resource::map { 'connection_upgrade':
    string   => '$http_upgrade',
    default  => upgrade,
    mappings => {
      "''"    => close,
    }
  }

  nginx::resource::server {
    'catch-unknown':
      server_name         => ['_'],
      listen_port         => 80,
      ipv6_listen_port    => 80,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      raw_append          => 'return 444;';

    'downstream-proxy':
      # This is used for hosts that don't directly point to lb-kubernetes, but
      # are instead reverse proxied from another server (like puppet, www, irc)
      # This points to the same backend as other requests, but doesn't handle
      # alias redirects or TLS termination. In these cases, TLS is handled by
      # the upstream reverse proxy.
      server_name         => ['_'],
      listen_port         => 4080,
      ipv6_listen_port    => 4080,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      proxy               => 'http://kubernetes',
      proxy_set_header    => [
        'Host $host',
      ];
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'auth':
    server_name    => 'auth.ocf.berkeley.edu',
    server_aliases => ['auth', 'auth.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'grafana':
    server_name    => 'grafana.ocf.berkeley.edu',
    server_aliases => ['grafana', 'grafana.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'ircbot':
    server_name    => 'ircbot.ocf.berkeley.edu',
    server_aliases => ['ircbot', 'ircbot.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'kanboard':
    server_name    => 'kanboard.ocf.berkeley.edu',
    server_aliases => ['kanboard', 'kanboard.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'kube':
    server_name    => 'kube.ocf.berkeley.edu',
    server_aliases => ['kube', 'kube.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'kubeadmin':
    server_name    => 'kubeadmin.ocf.berkeley.edu',
    server_aliases => ['kubeadmin', 'kubeadmin.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'labmap':
    server_name    => 'labmap.ocf.berkeley.edu',
    server_aliases => ['labmap', 'labmap.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'mastodon':
    server_name    => 'mastodon.ocf.berkeley.edu',
    server_aliases => ['mastodon', 'mastodon.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'pma':
    server_name    => 'pma.ocf.berkeley.edu',
    server_aliases => ['pma', 'pma.ocf.io', 'phpmyadmin', 'phpmyadmin.ocf.io', 'phpmyadmin.ocf.berkeley.edu'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'metabase':
    server_name    => 'metabase.ocf.berkeley.edu',
    server_aliases => ['metabase', 'metabase.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'rt':
    server_name    => 'rt.ocf.berkeley.edu',
    server_aliases => ['rt', 'rt.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'inventory':
    server_name    => 'inventory.ocf.berkeley.edu',
    server_aliases => ['inventory', 'inventory.ocf.io'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'sourcegraph':
    server_name    => 'sourcegraph.ocf.berkeley.edu',
    server_aliases => ['sg', 'sg.ocf.io', 'sourcegraph', 'sourcegraph.ocf.io', 'sg.ocf.berkeley.edu'],
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'static':
    server_name    => 'static.ocf.berkeley.edu',
  }

  ocf_kubernetes::master::loadbalancer::http_vhost { 'templates':
    server_name    => 'templates.ocf.berkeley.edu',
    server_aliases => ['templates', 'templates.ocf.io'],
  }
}
