class ocf_printhost::monitor {
  include ocf::node_exporter

  package { ['libcups2-dev', 'python3-cups', 'python3-prometheus-client']: }

  file {
    '/usr/local/bin/monitor-cups':
      source => 'puppet:///modules/ocf_printhost/monitor-cups',
      mode   => '0755';
  } ->
  exec { 'monitor-cups-initial':
    command => '/usr/local/bin/monitor-cups /srv/prometheus/cups.prom',
    creates => '/srv/prometheus/cups.prom',
  } ->
  cron { 'monitor-cups':
    command => '/usr/local/bin/monitor-cups /srv/prometheus/cups.prom',
    # Run every minute
  }
}
