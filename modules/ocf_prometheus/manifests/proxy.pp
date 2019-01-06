class ocf_prometheus::proxy {
  include apache
  include apache::mod::proxy
  include apache::mod::proxy_http

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
        {rewrite_rule => '^/alertmanager(/.*)?$ http://127.0.0.1:9093/alertmanager$1 [P]'},
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
