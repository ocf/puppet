class ocf_prometheus::proxy {
  include apache
  include apache::mod::proxy
  include apache::mod::proxy_http

  $cname = $::host_env ? {
    'dev'  => 'dev-prometheus',
    'prod' => 'prometheus',
  }

  package { 'libapache2-mod-authnz-pam':; }

  apache::mod { 'authnz_pam':
    require => Package['libapache2-mod-authnz-pam'];
  }

  file {
    '/etc/prometheus/allowed-groups':
      content => 'ocfstaff';
    '/etc/pam.d/ocfprometheus':
      source  => 'puppet:///modules/ocf_prometheus/proxy_pam',
      require => File['/etc/prometheus/allowed-groups'];
  }

  ocf::privatefile { '/etc/prometheus/htpasswd':
    source => 'puppet:///private/htpasswd',
    owner  => 'www-data',
    mode   => '400';
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
        {rewrite_rule => '^/pushgateway(/.*)?$ http://127.0.0.1:9091$1 [P]'},
        {rewrite_rule => '^/(.*)$ http://127.0.0.1:9090/$1 [P]'},
      ],
      directories         => [{
        provider            => proxy,
        path                => '*',
        auth_type           => 'Basic',
        auth_name           => 'OCF Account',
        auth_basic_provider => 'file PAM',
        auth_user_file      => '/etc/prometheus/htpasswd',
        require             => {requires => ['valid-user', 'local'], enforce => 'Any'},
        custom_fragment     => 'AuthPAMService ocfprometheus',
      }],
      require             => [
        Apache::Mod['authnz_pam'],
        File['/etc/pam.d/ocfprometheus'],
        Ocf::Privatefile['/etc/prometheus/htpasswd'],
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
