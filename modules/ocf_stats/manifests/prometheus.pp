# prometheus daemon config
class ocf_stats::prometheus {
  class { '::prometheus':
    version        => '2.0.0',
    alerts         => {},
    scrape_configs => [
      { 'job_name' => 'prometheus',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          { 'targets' => [ 'localhost:9090' ],
            'labels'  => { 'alias' => 'Prometheus' }
          }
        ]
      },
      { 'job_name' => 'node',
        'scrape_interval' => '5s',
        'scrape_timeout'  => '5s',
        'static_configs'  => [
          { 'targets' => [
            # A list of all hosts to scrape.
            # We should probably figure out a better way of enumerating all the
            # hosts.
            'leprosy:9100',
          ]
          }
        ]
      }
    ]
  }

  # TODO: eventually roll out node exporting to all hosts, instead of just here
  include prometheus::node_exporter
}
