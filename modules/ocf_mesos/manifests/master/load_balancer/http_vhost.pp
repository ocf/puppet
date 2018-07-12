# Proxy HTTP and possibly HTTPS requests to a Marathon service.
#
# Because HTTP services can use name-based virtual hosts, all HTTP vhosts bind
# to the same IP (currently 169.229.226.53).
#
# By default, it will be an HTTP-only service. If $ssl is true, it will be
# HTTPS-only, which a 301 redirect from HTTP -> HTTPS.
# We don't currently support both HTTP and HTTPS services.
define ocf_mesos::master::load_balancer::http_vhost(
  $server_name,
  $service_port,
  $server_aliases = [],
  $ssl            = true,
  $ssl_domains    = [$server_name],
  $ssl_dhparam    = '/etc/ssl/dhparam.pem',
) {
  ocf::ssl::bundle { $server_name:
    domains => $ssl_domains,
  }

  ocf::nginx_proxy { $title:
    server_name    => $server_name,
    server_aliases => $server_aliases,
    proxy          => "http://localhost:${service_port}",

    ssl            => $ssl,
    ssl_cert       => "/etc/ssl/private/${server_name}.crt",
    ssl_key        => "/etc/ssl/private/${server_name}.key",
    ssl_dhparam    => $ssl_dhparam,
  }
}
