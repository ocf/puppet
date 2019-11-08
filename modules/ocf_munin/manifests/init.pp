# munin master config
class ocf_munin {
  include apache
  include ocf::firewall::allow_web
  include ocf::ssl::default

  package {
    ['munin', 'nmap']:;
  }

  service { 'munin':
    require => Package['munin'];
  }

  $cname = $::host_env ? {
    'dev'  => 'dev-munin',
    'prod' => 'munin',
  }

  file {
    '/etc/munin/munin.conf':
      source  => 'puppet:///modules/ocf_munin/munin.conf',
      mode    => '0644',
      notify  => Service['munin'],
      require => Package['munin'];
    '/usr/local/bin/gen-munin-nodes':
      source => 'puppet:///modules/ocf_munin/gen-munin-nodes',
      mode   => '0755';
    '/usr/local/bin/mail-munin-alert':
      content => template('ocf_munin/mail-munin-alert.erb'),
      mode    => '0755';
  }

  # Generate munin nodes on the 3rd minute of every hour to avoid conflicting
  # with periodic Munin checks every 5 minutes (rt#4712)
  ocf::exec_and_cron { 'gen-munin-nodes':
    command      => '/usr/local/bin/gen-munin-nodes > /etc/munin/munin-conf.d/nodes',
    creates      => '/etc/munin/munin-conf.d/nodes',
    cron_options =>  {
      user    => 'root',
      minute  => '03',
      notify  => Service['munin'],
      require => File['/usr/local/bin/gen-munin-nodes'],
    },
  }

  include apache::mod::fcgid
  include apache::mod::rewrite

  # Restart apache if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Apache::Service']

  apache::vhost {
    'munin':
      servername    => "${cname}.ocf.berkeley.edu",
      port          => 443,
      docroot       => '/var/cache/munin/www/static/',
      docroot_owner => 'munin',
      docroot_group => 'munin',

      ssl           => true,
      ssl_key       => "/etc/ssl/private/${::fqdn}.key",
      ssl_cert      => "/etc/ssl/private/${::fqdn}.crt",
      ssl_chain     => "/etc/ssl/private/${::fqdn}.intermediate",

      headers       => ['always set Strict-Transport-Security max-age=31536000'],

      rewrites      => [
        {rewrite_rule => '^/favicon.ico /var/cache/munin/www/static/favicon.ico [L]'},
        {rewrite_rule => '^/static/(.*) /var/cache/munin/www/static/$1 [L]'},
        {rewrite_rule => '^(/.*\.html)?$ /munin-cgi/munin-cgi-html/$1 [PT]'},
        {rewrite_rule => '^/munin-cgi/munin-cgi-graph/(.*) /$1'},
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

      directories   => [
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
      ],

      require       => Package['munin'];

    'munin-redirect':
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
