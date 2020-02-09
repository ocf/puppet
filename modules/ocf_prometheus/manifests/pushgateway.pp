class ocf_prometheus::pushgateway {

  ocf::firewall::firewall46 {
    '995 allow pushgateway to accept metrics':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 9091,
        action => 'accept',
      };
  }

  class { '::prometheus::pushgateway':
    version       => '1.0.0',
    extra_options => "--web.route-prefix=/ --web.external-url=\"https://prometheus.ocf.berkeley.edu/pushgateway\"",
  }
}
