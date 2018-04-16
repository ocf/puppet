# prometheus daemon config
class ocf_stats::prometheus {
  # The list of nodes to monitor-- for now, monitor all hosts.
  $nodes_query = '["from", "nodes", ["=", "expired", null]]'
  $nodes = sort(puppetdb_query($nodes_query).map |$value| { $value["certname"] })

  class { '::prometheus':
    version        => '2.0.0',
    extra_options  => '--web.listen-address="127.0.0.1:9090" --web.external-url=http://127.0.0.1/prom',
    alerts         => {},
    scrape_configs => [
      {
        'job_name'        => 'prometheus',
        'scrape_interval' => '10s',
        'scrape_timeout'  => '10s',
        'static_configs'  => [
          {
            'targets' => [ 'localhost:9090' ],
            'labels'  => { 'alias' => 'Prometheus' },
          },
        ],
      },
      {
        'job_name'        => 'node',
        'scrape_interval' => '5s',
        'scrape_timeout'  => '5s',
        'static_configs'  => [
          {
            'targets' => $nodes.map |$hostname| {
	    	"${hostname}:9100"
	    },
          },
        ],
      }
    ]
  }
}
