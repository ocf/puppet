class ocf_lb {
  include ocf::firewall::allow_web
  include ocf_lb::keepalived

  $ssl_cert = "/etc/ssl/private/${::fqdn}.pem"

  $kubernetes_prod_worker_nodes = lookup('kubernetes::worker_nodes')
  $kubernetes_prod_workers = $kubernetes_prod_worker_nodes.map |$worker| { [$worker, ldap_attr($worker, 'ipHostNumber')] }

  $kubernetes_prod_services =
  [
    'auth',
    'grafana',
    'ircbot',
    'kanboard',
    'labmap',
    'mastodon',
    ['pma', ['phpmyadmin']],
    'metabase',
    'rt',
    'inventory',
    ['sourcegraph', ['sg']],
    'static',
    'templates',
  ]

  $kubernetes_prod_aliases = ocf_lb::gen_aliases($kubernetes_prod_services)

  $kubernetes_prod_proxy =
  [
    'irc',
    'puppet',
    'snmp-exporter',
    'www',
  ]

  package { 'haproxy': }

  file { '/etc/haproxy/haproxy.cfg':
    content => template('ocf_lb/haproxy.cfg.erb'),
    require => Package['haproxy'],
  }

  service { 'haproxy': }

  class { 'ocf_lb::ssl':
    vip => 'lb',
  }

  # Reload HAProxy if any of the certs change
  Concat[$ssl_cert] ~> Service[haproxy]

  # Reload HAProxy if the config changes
  File['/etc/haproxy/haproxy.cfg'] ~> Service[haproxy]
}
