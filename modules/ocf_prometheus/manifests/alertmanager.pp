class ocf_prometheus::alertmanager {

  if $::host_env == 'dev' {
    $hostname = 'dev-prometheus'
  } else {
    $hostname = 'prometheus'
  }

  ocf::firewall::firewall46 {
    '995 allow prometheus alertmanager to send on SMTP port':
      opts    => {
        chain       => 'PUPPET-OUTPUT',
        proto       => 'tcp',
        destination => 'smtp',
        dport       => 25,
        uid         => 'alertmanager',
        action      => 'accept',
      },
      before  => undef,
      require => User['alertmanager'],
  }

  class { '::prometheus::alertmanager':
    version       => '0.15.2',

    extra_options => "--cluster.advertise-address=${::ipaddress}:9094 --web.external-url=\"https://${hostname}.ocf.berkeley.edu/alertmanager\"",

    global        => {
      'smtp_smarthost'   => 'smtp.ocf.berkeley.edu:25',
      'smtp_from'        => 'root@ocf.berkeley.edu',
      'smtp_require_tls' => false,
    },

    route         => {
      group_by => ['alertname'],
      receiver => 'default',
      routes   => [
        {
          # Repeat MirrorOutOfDate alerts every 24h, instead of the default 4h
          match           => {'alertname' => 'MirrorOutOfDate'},
          repeat_interval => '24h',
          receiver        => 'ocf_lowprio',
        },
  {
    match           => {'alertname' => 'PaperEmpty'},
    group_wait      => '0s',
    repeat_interval => '10s',
    receiver        => 'opstaff_irc_alerts',
  },
      ],
    },

    receivers     => [
      {
        name          => 'default',
      },
      {
        name          => 'ocf_lowprio',
        email_configs => [{ to => 'mon@ocf.berkeley.edu' }],
      },
      {
        name            => 'opstaff_irc_alerts',
        webhook_configs => [{ url => 'http://calamity.ocf.berkeley.edu:8014/alerts'  }],
      },
    ],

    inhibit_rules => [],
  }
}
