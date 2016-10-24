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

  $ssl = false,
  $ssl_cert = undef,
  $ssl_key = undef,
  $ssl_dhparam = '/etc/ssl/dhparam.pem',
) {
  nginx::resource::upstream { "marathon_service_${service_port}":
    members => ["localhost:${service_port}"],
  }

  if $ssl {
    nginx::resource::vhost { "${title}-https":
      server_name => $server_name,
      proxy       => "http://marathon_service_${service_port}",

      ssl         => true,
      ssl_cert    => $ssl_cert,
      ssl_key     => $ssl_key,
      ssl_dhparam => $ssl_dhparam,

      rewrite_to_https => true,
    }
  } else {
    nginx::resource::vhost { "${title}-http":
      server_name => $server_name,
      proxy       => "http://marathon_service_${service_port}",
    }
  }
}
