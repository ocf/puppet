class ocf_prometheus::server {
  include ocf::firewall::allow_web
  include ocf::ssl::default

  file {
    '/usr/local/bin/gen-prometheus-nodes':
      source => 'puppet:///modules/ocf_prometheus/gen-prometheus-nodes',
      mode   => '0755';
  } ->
  exec { 'gen-promethues-nodes-initial':
    command => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-nodes.json',
    creates => '/var/local/prometheus-nodes.json',
  } ->
  cron { 'gen-prometheus-nodes':
    command => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-nodes.json',
    minute  => '0',
  }

  file {
    '/usr/local/bin/gen-prometheus-printers':
      source => 'puppet:///modules/ocf_prometheus/gen-prometheus-printers',
      mode   => '0755';
  } ->
  exec { 'gen-prometheus-printers-initial':
    command => '/usr/local/bin/gen-prometheus-printers /var/local/prometheus-printers.json',
    creates => '/var/local/prometheus-printers.json',
  } ->
  cron { 'gen-prometheus-printers':
    command => '/usr/local/bin/gen-prometheus-printers /var/local/prometheus-printers.json',
    minute  => '0',
  }

  file {
    '/etc/prometheus/marathon_passwd':
      content   => lookup('mesos::marathon::http_password'),
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
  } -> Service[prometheus]

  class { '::prometheus::server':
    version              => '2.6.0',
    extra_options        => '--web.listen-address="127.0.0.1:9090"',
    external_url         => 'https://prometheus.ocf.berkeley.edu',
    rule_files           => [ '/etc/prometheus/rules.d/*.yml' ],
    alertmanagers_config => [{
      'scheme'         => 'https',
      'path_prefix'    => '/alertmanager',
      'static_configs' => [{
        'targets' => ['prometheus.ocf.berkeley.edu'],
      }],
    }],
    scrape_configs       => [
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
        'scrape_interval' => '10s',
        'scrape_timeout'  => '5s',

        'file_sd_configs' => [
          {
            'files'            => [ '/var/local/prometheus-nodes.json' ],
            # Prometheus will auto-detect updates to this file, so this
            # refresh interval is only a fallback.
            'refresh_interval' => '1h',
          },
        ],
      },
      {
        'job_name'        => 'printer',
        'scrape_interval' => '30s',
        'scrape_timeout'  => '20s',

        'file_sd_configs' => [
          {
            'files'            => [ '/var/local/prometheus-printers.json' ],
            'refresh_interval' => '1h',
          },
        ],

        'metrics_path'    => '/snmp',
        'params'          => { 'module' => [ 'printer' ]},

        # Relabel trick to make sure we scrape from the exporter and not from
        # the printers themselves, see
        # https://github.com/prometheus/snmp_exporter#prometheus-configuration
        'relabel_configs' => [
          {
            'source_labels' => [ '__address__' ],
            'target_label'  => '__param_target',
          },
          {
            'target_label' => '__address__',
            'replacement'  => 'lb.ocf.berkeley.edu:10020',
          },
        ]
      },
      {
        'job_name'            => 'marathon',
        'scrape_interval'     => '10s',
        'scrape_timeout'      => '10s',

        'marathon_sd_configs' => [
          {
            'servers'    => keys(lookup('mesos_masters')).map |$m| { "http://${m}:8080" },
            'basic_auth' => {
              username      => 'marathon',
              password_file => '/etc/prometheus/marathon_passwd',
            },
          },
        ],

        'relabel_configs'     => [
          {
            source_labels => ['__meta_marathon_app'],
            regex         => '/grafana|/ocfweb/web',
            action        => 'keep',
          },
          {
            source_labels => ['__meta_marathon_app'],
            target_label  => 'marathon_app',
          },
          {
            source_labels => ['__meta_marathon_image'],
            target_label  => 'marathon_image',
          },
          {
            source_labels => ['__meta_marathon_task'],
            target_label  => 'marathon_task',
          },
        ],
      },
    ]
  }
}
