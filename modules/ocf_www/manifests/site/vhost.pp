# A single virtual host.
define ocf_www::site::vhost($vhost = $title) {
  # Common config for all <VirtualHost> blocks for this vhost.
  Apache::Vhost {
    vhost_name      => '*',
    serveradmin     => "${vhost[username]}@ocf.berkeley.edu",
    docroot         => $vhost[full_docroot],

    access_log_file => 'vhost-access.log',
    error_log_file  => 'vhost-error.log',

    manage_docroot  => false,
  }

  # The <VirtualHost> that actually serves their website.
  $headers = $vhost[use_hsts] ? {
    true    => ["set Strict-Transport-Security 'max-age=31536000'"],
    default => [],
  }
  $primary_port = $vhost[use_ssl] ? {
    true    => 443,
    default => 80,
  }

  $canonical_url = $vhost[use_ssl] ? {
    true    => "https://${vhost[domain]}/",
    default => "http://${vhost[domain]}/",
  }

  apache::vhost { "vhost-${vhost[domain]}":
    servername        => $vhost[domain],

    ssl               => $vhost[use_ssl],
    port              => $primary_port,

    ssl_key           => $vhost[ssl_key],
    ssl_cert          => $vhost[ssl_cert],
    ssl_chain         => $vhost[ssl_chain],

    headers           => $headers,
    suexec_user_group => "${vhost[username]} ocf",

    # 301 redirects are more correct but get cached forever by dumb browsers
    # like Chrome; for vhosts, we don't really care too much about 301s
    redirect_status   => '302',
    redirect_dest     => $vhost[redirect_dest],

    directories       => [
      {
        # TODO: try to reduce duplication between here and www for /services
        path           => $vhost[full_docroot],
        provider       => 'directories',
        directoryindex => 'index.html index.cgi index.pl index.php index.xhtml index.htm index.shtm index.shtml',
        options        => [
          'ExecCGI',
          'IncludesNoExec',
          'Indexes',
          'MultiViews',
          'SymLinksIfOwnerMatch',
        ],
        allow_override => ['All'],
      },
      {
        path       => '/services/http/suexec',
        provider   => 'directories',
        sethandler => 'fastcgi-script',
        options    => ['+ExecCGI'],
      },
      {
        path       => '\.ph(p3?|tml)$',
        provider   => 'filesmatch',
        sethandler => 'php5-fcgi',
      },
    ],

    aliases => [
      {
        alias => '/.well-known',
        path  => '/srv/well-known',
      },
    ],

    custom_fragment   => "
      Action php5-fcgi /php5-fcgi
      Alias /php5-fcgi /services/http/suexec/php5-fcgi-wrapper
      UserDir disabled
      suPHP_Engine off
    ",
  }

  if !empty($vhost[http_aliases]) {
    apache::vhost { "vhost-${vhost[domain]}-redirect":
      servername      => "${vhost[domain]}-redirect",
      serveraliases   => $vhost[http_aliases],

      port            => 80,

      redirect_status => 'permanent',
      redirect_dest   => $canonical_url,
    }
  }
}
