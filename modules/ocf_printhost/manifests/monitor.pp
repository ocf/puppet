class ocf_printhost::monitor {
  package { ['libcups2-dev', 'python3-cups', 'python3-prometheus-client']: }

  file {
    '/var/local/prometheus':
      ensure => directory;
  } ->
  file {
    '/usr/local/bin/monitor-cups':
      source => 'puppet:///modules/ocf_printhost/monitor-cups',
      mode   => '0755';
  } ->
  exec { 'monitor-cups-initial':
    command => '/usr/local/bin/monitor-cups /var/local/prometheus/cups.prom',
    creates => '/var/local/prometheus/cups.prom',
  } ->
  cron { 'monitor-cups':
    command => '/usr/local/bin/monitor-cups /var/local/prometheus/cups.prom',
    # Run every minute
  }
}
