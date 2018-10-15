class ocf_prometheus::alertmanager {
  ocf::firewall::firewall46 {
    '995 allow prometheus alertmanager to send on SMTP port':
      opts   => {
        chain       => 'PUPPET-OUTPUT',
        proto       => 'tcp',
        destination => 'smtp',
        dport       => 25,
        uid         => 'alertmanager',
        action      => 'accept',
      },
      before => undef,
  }

  class { '::prometheus::alertmanager':
    version       => '0.15.2',

    extra_options => "--cluster.advertise-address=${::ipaddress}:9094 --web.external-url=\"https://prometheus.ocf.berkeley.edu/alertmanager\"",

    global        => {
      'smtp_smarthost'   => 'smtp.ocf.berkeley.edu:25',
      'smtp_from'        => 'root@ocf.berkeley.edu',
      'smtp_require_tls' => false,
    },

    route         => {
      group_by => ['alertname'],
      receiver => 'ocf_lowprio',
    },

    receivers     => [
      {
        name          => 'ocf_lowprio',
        email_configs => [{ to => 'mon@ocf.berkeley.edu' }],
      },
    ],

    inhibit_rules => [],
  }
}
