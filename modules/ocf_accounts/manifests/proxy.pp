class ocf_accounts::proxy {
  class { 'nginx':
    # if we let nginx manage its own repo, it uses the `apt` module; this
    # creates an unresolvable dependency cycle because we declare class `apt`
    # in stage first (and we're currently in stage main)
    manage_repo => false;
  }

  nginx::resource::upstream { 'atool':
    members => ['localhost:8000'];
  }

  nginx::resource::vhost {
    'accounts.ocf.berkeley.edu':
      server_name => [
        'accounts.ocf.berkeley.edu',
        'dev-accounts.ocf.berkeley.edu'
      ],

      proxy            => 'http://atool',
      proxy_set_header => [
        'X-Forwarded-Protocol $scheme',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $http_host'
      ],

      ssl      => true,
      ssl_cert => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key  => "/etc/ssl/private/${::fqdn}.key",

      listen_port      => 443,
      rewrite_to_https => true;

    'accounts.ocf.berkeley.edu-redirect':
      # we have to specify www_root even though we always redirect
      www_root => '/var/www',

      server_name => [
        'account.ocf.berkeley.edu',
        $::hostname,
        $::fqdn
      ],

      ssl      => true,
      ssl_cert => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key  => "/etc/ssl/private/${::fqdn}.key",

      vhost_cfg_append => {
        'return' => '301 https://accounts.ocf.berkeley.edu$request_uri'
      };
  }
}
