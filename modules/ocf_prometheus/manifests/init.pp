# prometheus daemon config
class ocf_prometheus {
  include apache
  include apache::mod::proxy
  include apache::mod::proxy_http
  include ocf::firewall::allow_web
  include ocf::ssl::default

  file {
    '/usr/local/bin/gen-prometheus-nodes':
      source => 'puppet:///modules/ocf_prometheus/gen-prometheus-nodes',
      mode   => '0755';
  }

  cron { 'gen-prometheus-nodes':
    command => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-nodes.json',
    minute  => '0',
    require => File['/usr/local/bin/gen-prometheus-nodes'];
  }

  exec { 'gen-promethues-nodes-initial':
    command => '/usr/local/bin/gen-prometheus-nodes /var/local/prometheus-nodes.json',
    creates => '/var/local/prometheus-nodes.json',
  }

  file {
    '/usr/local/bin/gen-prometheus-printers':
      source => 'puppet:///modules/ocf_prometheus/gen-prometheus-printers',
      mode   => '0755';
  }

  cron { 'gen-prometheus-printers':
    command => '/usr/local/bin/gen-prometheus-printers /var/local/prometheus-printers.json',
    minute  => '0',
    require => File['/usr/local/bin/gen-prometheus-printers'];
  }

  exec { 'gen-promethues-printers-initial':
    command => '/usr/local/bin/gen-prometheus-printers /var/local/prometheus-printers.json',
    creates => '/var/local/prometheus-printers.json',
  }

  file {
    '/etc/prometheus/rules.d':
      ensure  => 'directory',
      source  => 'puppet:///modules/ocf_prometheus/rules.d',
      recurse => true;
  }

  class { '::prometheus::server':
    version        => '2.4.2',
    extra_options  => '--web.listen-address="127.0.0.1:9090"',
    rule_files     => [ '/etc/prometheus/rules.d/*' ],
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
        'scrape_interval' => '10s',
        'scrape_timeout'  => '5s',

        'file_sd_configs' => [
          {
            'files'            => [ '/var/local/prometheus-nodes.json' ],
            'refresh_interval' => '1h',
          },
        ],
      },
      {
        'job_name'        => 'printer',
        'scrape_interval' => '30s',
        'scrape_timeout'  => '5s',

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
      }
    ]
  }

  $cname = $::host_env ? {
    'dev'  => 'dev-prometheus',
    'prod' => 'prometheus',
  }

  apache::vhost {
    'prometheus':
      servername          => "${cname}.ocf.berkeley.edu",
      port                => 443,
      docroot             => '/var/www/html',
      ssl                 => true,
      ssl_key             => "/etc/ssl/private/${::fqdn}.key",
      ssl_cert            => "/etc/ssl/private/${::fqdn}.crt",
      ssl_chain           => "/etc/ssl/private/${::fqdn}.intermediate",

      headers             => ['always set Strict-Transport-Security max-age=31536000'],
      proxy_preserve_host => true,
      request_headers     => ['set X-Forwarded-Proto https'],

      rewrites            => [
        {rewrite_rule => '^/(.*)$ http://127.0.0.1:9090/$1 [P]'},
      ];

    'prometheus-http-redirect':
      servername      => "${cname}.ocf.berkeley.edu",
      serveraliases   => [
        $cname,
      ],
      port            => 80,
      docroot         => '/var/www/html',

      redirect_status => 301,
      redirect_dest   => "https://${cname}.ocf.berkeley.edu/";
  }
}
