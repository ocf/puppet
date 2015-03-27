# munin master config
class ocf_stats::munin {
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
  }

  cron { 'gen-munin-nodes':
    command => '/usr/local/bin/gen-munin-nodes > /etc/munin/munin-conf.d/nodes',
    special => 'hourly',
    notify  => Service['munin'];
  }

  include apache::mod::fcgid
  include apache::mod::rewrite

  apache::vhost { 'munin.ocf.berkeley.edu':
    serveraliases => ['munin'],
    port          => 80,
    docroot       => '/var/cache/munin/www/static/',

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
        path  => '/var/cache/munin/www/static/',
        allow => 'from all'
      },
      {
        path       => '/munin-cgi/munin-cgi-html',
        provider   => location,
        options    => '+ExecCGI',
        sethandler => 'fcgid-script',
        allow      => 'from all'
      },
      {
        path       => '/munin-cgi/munin-cgi-graph',
        provider   => location,
        options    => '+ExecCGI',
        sethandler => 'fcgid-script',
        allow      => 'from all'
      }
    ];
  }
}
