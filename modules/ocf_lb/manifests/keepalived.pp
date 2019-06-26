# Virtual IP configuration for the load balancer
class ocf_lb::keepalived {

  # At any given time, only one load balancer will hold
  # the first IP. The master holding the IP will handle all
  # HAProxy requests and forward them.

  # IPv6 addresses have to be specified separately as they cannot be in the vrrp
  # packet together (keepalived 1.2.20+) so they need to be in a
  # virtual_ipaddress_excluded block instead.
  $virtual_addresses = [
    # Primary load balancer IP (v4)
    '169.229.226.53',
  ]
  $virtual_addresses_v6 = [
    # Primary load balancer IP (v6)
    '2607:f140:8801::1:53',
  ]
  $keepalived_secret = lookup('lb::keepalived::secret')

  package { 'keepalived':; } ->
  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_lb/keepalived.conf.erb'),
    mode    => '0400',
  } ~>
  service { 'keepalived': }
}
