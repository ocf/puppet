define ocf::nginx_proxy(
  $proxy,
  $proxy_redirect   = undef,
  $proxy_set_header = [],

  $server_name    = $title,
  $server_aliases = [],
  $headers        = {},

  $ssl         = false,
  $ssl_cert    = "/etc/ssl/private/${::fqdn}.bundle",
  $ssl_key     = "/etc/ssl/private/${::fqdn}.key",
  $ssl_dhparam = '/etc/ssl/dhparam.pem',

  # Accept any other arbitrary options passed in and pass them on to
  # nginx::resource::server
  $nginx_options = {},
) {

  $base_headers = [
    'Host $host',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
    'X-Forwarded-Proto $scheme',
    'X-Real-IP $remote_addr',
  ]

  if $ssl {
    nginx::resource::server {
      $title:
        server_name      => [$server_name],
        proxy            => $proxy,
        proxy_redirect   => $proxy_redirect,
        proxy_set_header => concat($base_headers, $proxy_set_header),

        listen_port      => 443,
        ssl              => true,
        ssl_cert         => $ssl_cert,
        ssl_key          => $ssl_key,
        ssl_dhparam      => $ssl_dhparam,

        add_header       => merge({
          # HSTS header
          'Strict-Transport-Security' => 'max-age=31536000',
        }, $headers),

        *                => $nginx_options;

      "${title}-redirect":
        server_name       => concat([$server_name], $server_aliases),
        server_cfg_append => {
          'return' => "301 https://${server_name}\$request_uri"
        },

        # We have to specify www_root even though we always redirect/proxy
        www_root          => '/var/www',
        add_header        => $headers,
        *                 => $nginx_options;
    }

    if size($server_aliases) > 0 {
      nginx::resource::server {
        "${title}-aliases-redirect":
          server_name       => $server_aliases,
          server_cfg_append => {
            'return' => "301 https://${server_name}\$request_uri"
          },

          listen_port       => 443,
          ssl               => true,
          ssl_cert          => $ssl_cert,
          ssl_key           => $ssl_key,
          ssl_dhparam       => $ssl_dhparam,

          add_header        => merge({
            # HSTS header
            'Strict-Transport-Security' => 'max-age=31536000',
          }, $headers),

          # We have to specify www_root even though we always redirect/proxy
          www_root          => '/var/www',
          *                 => $nginx_options;
      }
    }
  } else {
    nginx::resource::server { $title:
      server_name      => concat([$server_name], $server_aliases),
      proxy            => $proxy,
      proxy_redirect   => $proxy_redirect,
      proxy_set_header => concat($base_headers, $proxy_set_header),
      add_header       => $headers,
      *                => $nginx_options,
    }
  }
}
