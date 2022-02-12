class ocf_prometheus::pushgateway {

  class { 'prometheus::pushgateway':
    version       => '1.4.2',
    extra_options => "--web.route-prefix=/ --web.external-url=\"https://prometheus.ocf.berkeley.edu/pushgateway\"",
  }
}
