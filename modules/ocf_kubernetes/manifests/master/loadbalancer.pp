class ocf_kubernetes::master::loadbalancer {
  include ocf::firewall::allow_web

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers = $kubernetes_worker_nodes.map |$worker| {
    [$worker, ldap_attr($worker, 'ipHostNumber')]
  }

  $kubernetes_services = [
    'api',
    'auth',
    'badges',
    'badgr-api',
    'chat',
    'code',
    'cruisecontrol',
    'discord',
    'fava',
    'grafana',
    'help',
    'inventory',
    'ircbot',
    'irclogs',
    'jukebox',
    'kanboard',
    'kube',
    'kubeadmin',
    'labmap',
    'lambda',
    'mastodon',
    'matrix',
    'metabase',
    'new',
    'notes',
    'pma',
    'printlist',
    'prometheus-kube',
    'rt',
    'sourcegraph',
    'static',
    'templates',
    'vaultwarden',
  ]

  # redirects happen post-canonicalization, so needs fqdn
  $kubernetes_aliases = [
    ['pma.ocf.berkeley.edu', 'phpmyadmin.ocf.berkeley.edu'],
    ['sourcegraph.ocf.berkeley.edu', 'sg.ocf.berkeley.edu'],
  ]

  $kubernetes_internal_services = [
    'irc',
    'puppet',
    'snmp-exporter',
    'www',
  ]

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
  class { 'ocf_lb':
    vip_names                => ['lb'],
    keepalived_secret_lookup => 'kubernetes::keepalived::secret',
    vrid                     => 51,
  }

  package { 'haproxy': }

  file { '/etc/haproxy/haproxy.cfg':
    content => template('ocf_kubernetes/master/loadbalancer/haproxy.cfg.erb'),
    require => Package['haproxy'],
  } ~>
  service { 'haproxy':
    subscribe => Ocf::Ssl::Bundle['lb.ocf.berkeley.edu'],
  }
}
