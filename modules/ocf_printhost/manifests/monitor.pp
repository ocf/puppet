class ocf_printhost::monitor {
  package { ['libcups2-dev', 'python3-cups', 'python3-prometheus-client']: }

  file {
    '/usr/local/bin/monitor-cups':
      source => 'puppet:///modules/ocf_printhost/monitor-cups',
      mode   => '0755';
  } ->
  exec { 'monitor-cups-initial':
    command => '/usr/local/bin/monitor-cups /srv/prometheus/cups.prom',
    creates => '/srv/prometheus/cups.prom',
    require => File['/srv/prometheus'],
  } ->
  cron { 'monitor-cups':
    command => '/usr/local/bin/monitor-cups /srv/prometheus/cups.prom',
    # Run every minute
  }
}
