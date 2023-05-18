class ocf_prometheus::server {
  include ocf::firewall::allow_web
  include ocf::ssl::default

  file {
    '/usr/local/bin/gen-prometheus-nodes':
      source => 'puppet:///modules/ocf_prometheus/gen-prometheus-nodes',
      mode   => '0755';
  }

  ocf::exec_and_cron { 'gen-prometheus-nodes':
    command      => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-nodes.json --port 9100',
    creates      => '/var/local/prometheus-nodes.json',
    cron_options => { minute=>'0'},
    require      => File['/usr/local/bin/gen-prometheus-nodes'],
  }

  ocf::exec_and_cron { 'gen-prometheus-printers':
    command      => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-printers.json printer',
    creates      => '/var/local/prometheus-printers.json',
    cron_options => { minute=>'0'},
    require      => File['/usr/local/bin/gen-prometheus-nodes'],
  }

  ocf::exec_and_cron { 'gen-prometheus-switches':
    command      => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-switches.json switch',
    creates      => '/var/local/prometheus-switches.json',
    cron_options => { minute=>'0'},
    require      => File['/usr/local/bin/gen-prometheus-nodes'],
  }

  file {
    # TODO: we can probably get rid of our need for this by using firewall rules
    # insetad of HTTP basic auth, but this is easiest for now.
    '/etc/prometheus/docker_metrics_passwd':
      content   => lookup('prometheus::docker_metrics_password'),
      show_diff => false,
      owner     => 'prometheus',
      group     => 'prometheus',
      mode      => '0400';

    '/etc/prometheus/rules.d':
      ensure  => 'directory',
      source  => 'puppet:///modules/ocf_prometheus/rules.d',
      recurse => true,
      ignore  => '*.swp',
      purge   => true,
  } ~> Service[prometheus]

  class { 'prometheus::server':
    version              => '2.32.1',
    extra_options        => '--web.listen-address="127.0.0.1:9090"',
    external_url         => 'https://prometheus.ocf.berkeley.edu',
    rule_files           => [ '/etc/prometheus/rules.d/*.yaml' ],
    group                => 'prometheus',
    config_mode          => '0755', # fix
    alertmanagers_config => [{
      scheme         => 'https',
      path_prefix    => '/alertmanager',
      static_configs => [{
        targets => ['prometheus.ocf.berkeley.edu'],
      }],
    }],
    scrape_configs       => [
      {
        job_name        => 'node',
        scrape_interval => '10s',
        scrape_timeout  => '5s',

        file_sd_configs => [
          {
            files            => [ '/var/local/prometheus-nodes.json' ],
            # Prometheus will auto-detect updates to this file, so this
            # refresh interval is only a fallback.
            refresh_interval => '1h',
          },
        ],
      },
      {
        job_name        => 'influx',
        scrape_interval => '10s',
        scrape_timeout  => '4s',

        static_configs  => [{targets => ['mirrors:9122']}],
      },
      {
        job_name        => 'printer',
        scrape_interval => '30s',
        scrape_timeout  => '20s',

        file_sd_configs => [
          {
            files            => [ '/var/local/prometheus-printers.json' ],
            refresh_interval => '1h',
          },
        ],

        metrics_path    => '/snmp',
        params          => { 'module' => [ 'printer' ]},

        # Relabel trick to make sure we scrape from the exporter and not from
        # the printers themselves, see
        # https://github.com/prometheus/snmp_exporter#prometheus-configuration
        relabel_configs => [
          {
            source_labels => [ '__address__' ],
            target_label  => '__param_target',
          },
          {
            target_label => '__address__',
            replacement  => 'snmp-exporter.ocf.berkeley.edu:4080',
          },
        ]
      },
      {
        job_name        => 'switch',
        scrape_interval => '60s',
        scrape_timeout  => '30s',

        file_sd_configs => [
          {
            files            => [ '/var/local/prometheus-switches.json' ],
            refresh_interval => '1h',
          },
        ],

        metrics_path    => '/snmp',
        params          => { 'module' => [ 'switch' ]},

        # Relabel trick to make sure we scrape from the exporter and not from
        # the switches themselves, see
        # https://github.com/prometheus/snmp_exporter#prometheus-configuration
        relabel_configs => [
          {
            source_labels => [ '__address__' ],
            target_label  => '__param_target',
          },
          {
            target_label => '__address__',
            replacement  => 'snmp-exporter.ocf.berkeley.edu:4080',
          },
        ]
      },
      {
        job_name        => 'www_apache',
        scrape_interval => '10s',
        scrape_timeout  => '10s',

        static_configs  => [{targets => ['www:9117']}],
      },
      {
        job_name        => 'slurm',
        scrape_interval => '30s',
        scrape_timeout  => '30s',

        static_configs  => [{targets => ['hpcctl:9341']}],
      },
      {
        job_name        => 'postfix',
        scrape_interval => '10s',
        scrape_timeout  => '10s',

        static_configs  => [{targets =>['smtp:9154']}],
      },
      {
        job_name       => 'pushgateway',
        honor_labels   => true,

        static_configs => [{targets =>['localhost:9091']}],
      },
      {
        job_name        => 'synapse',
        scrape_interval => '15s',

        metrics_path    => '/_synapse/metrics',
        scheme          => 'https',

        static_configs  => [{targets =>['matrix.ocf.berkeley.edu']}],
      },
      {
        job_name        => 'nvidia',
        scrape_interval => '15s',
        scrape_timeout  => '10s',

        static_configs  => [{targets =>['corruption:9835']}],
     }
    ]
  }
}
