# munin master config
class ocf_stats::munin {
  include ocf_ssl

  package {
    ['munin', 'nmap']:;
  }

  service { 'munin':
    require => Package['munin'];
  }

  file {
    '/etc/munin/munin.conf':
      source  => 'puppet:///modules/ocf_stats/munin/munin.conf',
      mode    => '0644',
      notify  => Service['munin'],
      require => Package['munin'];
    '/usr/local/bin/gen-munin-nodes':
      source  => 'puppet:///modules/ocf_stats/munin/gen-munin-nodes',
      mode    => '0755';
    '/usr/local/bin/mail-munin-alert':
      source  => 'puppet:///modules/ocf_stats/munin/mail-munin-alert',
      mode    => '0755';
  }

  # Generate munin nodes on the 3rd minute of every hour to avoid conflicting
  # with periodic Munin checks every 5 minutes (rt#4712)
  cron { 'gen-munin-nodes':
    command => '/usr/local/bin/gen-munin-nodes > /etc/munin/munin-conf.d/nodes',
    user => 'root',
    minute  => '03',
    notify  => Service['munin'],
    require => File['/usr/local/bin/gen-munin-nodes'];
  }

  include apache::mod::fcgid
  include apache::mod::rewrite

  apache::vhost {
    'munin':
      servername    => 'munin.ocf.berkeley.edu',
      port          => 443,
      docroot       => '/var/cache/munin/www/static/',

      ssl           => true,
      ssl_key       => "/etc/ssl/private/${::fqdn}.key",
      ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
      ssl_chain     => '/etc/ssl/certs/incommon-intermediate.crt',

      headers       => ['set Strict-Transport-Security max-age=31536000'],

      rewrites => [
        {
          rewrite_rule => '^/favicon.ico /var/cache/munin/www/static/favicon.ico [L]'
        },
        {
          rewrite_rule => '^/static/(.*) /var/cache/munin/www/static/$1 [L]'
        },
        {
          rewrite_rule => '^(/.*\.html)?$ /munin-cgi/munin-cgi-html/$1 [PT]'
        },
        {
          rewrite_rule => '^/munin-cgi/munin-cgi-graph/(.*) /$1'
        },
        {
          rewrite_cond => '%{REQUEST_URI} !^/static',
          rewrite_rule => '^/(.*.png)$  /munin-cgi/munin-cgi-graph/$1 [L,PT]'
        }
      ],

      scriptaliases => [
        {
          alias => '/munin-cgi/munin-cgi-html',
          path  => '/usr/lib/munin/cgi/munin-cgi-html'
        },
        {
          alias => '/munin-cgi/munin-cgi-graph',
          path  => '/usr/lib/munin/cgi/munin-cgi-graph'
        }
      ],

      directories => [
        {
          path         => '/var/cache/munin/www/static/',
          auth_require => 'all granted',
        },
        {
          path         => '/munin-cgi/munin-cgi-html',
          provider     => location,
          options      => '+ExecCGI',
          sethandler   => 'fcgid-script',
          auth_require => 'all granted',
        },
        {
          path         => '/munin-cgi/munin-cgi-graph',
          provider     => location,
          options      => '+ExecCGI',
          sethandler   => 'fcgid-script',
          auth_require => 'all granted',
        }
      ];

    'munin-redirect':
      servername      => 'munin.ocf.berkeley.edu',
      serveraliases   => [
        'munin',
      ],
      port            => 80,
      docroot         => '/var/www/html',

      redirect_status => 301,
      redirect_dest   => 'https://munin.ocf.berkeley.edu/';
  }
}
