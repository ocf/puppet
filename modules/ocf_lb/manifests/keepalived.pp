class ocf_lb::keepalived(
  Array[String] $virtual_addresses_v4,
  Array[String] $virtual_addresses_v6,
  String $secret_lookup,
  Integer[1, 255] $vrid,
) {
  $secret = lookup($secret_lookup)

  package { 'keepalived':; } ->
  file { '/etc/keepalived/keepalived.conf':
    content => template('ocf_lb/keepalived.conf.erb'),
    mode    => '0400',
  } ~>
  service { 'keepalived': }
}
