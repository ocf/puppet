# prometheus daemon config
class ocf_stats::prometheus {
  file {
    '/usr/local/bin/gen-prometheus-nodes':
      source => 'puppet:///modules/ocf_stats/prometheus/gen-prometheus-nodes',
      mode   => '0755';
  }

  cron { 'gen-prometheus-nodes':
    command => '/usr/local/bin/gen-prometheus-nodes > /var/local/prometheus-nodes.json',
    user    => 'root',
    minute  => '03',
    require => File['/usr/local/bin/gen-prometheus-nodes'];
  }

  class { '::prometheus':
    version        => '2.0.0',
    extra_options  => '--web.listen-address="127.0.0.1:9090" --web.external-url=http://127.0.0.1/prometheus --storage.tsdb.retention=2y',
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

        'file_sd_configs' => [
          {
            'files'            => [ '/var/local/prometheus-nodes.json' ],
            'refresh_interval' => '1h',
          },
        ],
      }
    ]
  }
}
