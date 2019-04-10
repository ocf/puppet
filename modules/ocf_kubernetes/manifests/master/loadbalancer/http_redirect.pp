# Redirect HTTP and HTTPS requests to their canonical URLs
define ocf_kubernetes::master::loadbalancer::http_redirect(
  $server_name,
  $server_aliases,
) {
  nginx::resource::server {
    "${server_name}-http-redirect":
      server_name       => $server_aliases,
      listen_port       => 80,
      server_cfg_append => {
        'return' => "301 https://${server_name}\$request_uri"
      };

    "${server_name}-alias-redirect":
      server_name       => $server_aliases,
      listen_port       => 443,
      ssl               => true,
      ssl_cert          => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key           => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam       => '/etc/ssl/dhparam.pem',

      add_header        => {
        'Strict-Transport-Security' =>  'max-age=31536000',
      },

      server_cfg_append => {
        'return' => "301 https://${server_name}\$request_uri"
      };
  }
}
