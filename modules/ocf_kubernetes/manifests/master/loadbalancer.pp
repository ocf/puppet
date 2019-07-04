class ocf_kubernetes::master::loadbalancer {
  include ocf::firewall::allow_web

  $kubernetes_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_workers = $kubernetes_worker_nodes.map |$worker| {
    [$worker, ldap_attr($worker, 'ipHostNumber')]
  }

  $kubernetes_services = [
    'auth',
    'grafana',
    'ircbot',
    'kanboard',
    'kube',
    'kubeadmin',
    'labmap',
    'mastodon',
    'pma',
    'metabase',
    'rt',
    'inventory',
    'sourcegraph',
    'static',
    'templates',
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

  $vip = 'lb'

  class { 'ocf_kubernetes::master::loadbalancer::ssl':
    vip => $vip,
  }

  package { 'haproxy': }

  file { '/etc/haproxy/haproxy.cfg':
    content => template('ocf_kubernetes/master/loadbalancer/haproxy.cfg.erb'),
    require => Package['haproxy'],
  } ~>
  service { 'haproxy': }
}
