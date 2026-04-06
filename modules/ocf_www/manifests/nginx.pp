# Nginx reverse proxy in front of Apache for slowloris protection.
# CR-soon oliverni: move to 80/443, put apache on 127.0.0.1:$backend_port
#
# Static vhosts (www, shorturl, etc.) are defined here.
# Dynamic user vhosts come from build-vhosts via /etc/nginx/ocf-vhost.conf.
class ocf_www::nginx {
  include ocf::ssl::default
  include ocf_www::nginx::firewall

  # CR-soon oliverni: change listen/ssl ports to 80/443
  $http_port = 8080
  $ssl_port  = 8443

  $backend = "http://127.0.0.1:${ocf_www::backend_port}"

  $ssl_cert = "/etc/ssl/private/${::fqdn}.bundle"
  $ssl_key  = "/etc/ssl/private/${::fqdn}.key"

  $proxy_headers = [
    'Host $host',
    'X-Forwarded-For $remote_addr',
    'X-Forwarded-Proto $scheme',
    'X-Real-IP $remote_addr',
  ]

  $www_canonical = $::host_env ? {
    'dev'  => 'dev-www.ocf.berkeley.edu',
    'prod' => 'www.ocf.berkeley.edu',
  }

  class { 'nginx':
    manage_repo            => false,
    confd_purge            => true,
    server_purge           => true,
    names_hash_bucket_size => 128,
    client_max_body_size   => '64M',
    log_format             => {
      'vhost' => '$host $remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"',
    },
    http_cfg_append        => {
      'include' => '/etc/nginx/ocf-vhost.conf',
    },
  }

  Class['ocf::ssl::default'] ~> Class['Nginx::Service']

  # HTTPS vhosts — all proxy to Apache
  nginx::resource::server {
    default:
      listen_port       => $ssl_port,
      ssl_port          => $ssl_port,
      ssl               => true,
      ssl_cert          => $ssl_cert,
      ssl_key           => $ssl_key,
      http2             => 'on',
      proxy             => $backend,
      proxy_set_header  => $proxy_headers,
      add_header        => {
        'Strict-Transport-Security' => 'max-age=31536000',
      };

    'www-ssl':
      server_name         => [
        'www.ocf.berkeley.edu', 'dev-www.ocf.berkeley.edu',
        'ocf.berkeley.edu', 'dev-ocf.berkeley.edu',
        'secure.ocf.berkeley.edu', $::fqdn,
        'accounts.ocf.berkeley.edu', 'dev-accounts.ocf.berkeley.edu',
        'wiki.ocf.berkeley.edu', 'dev-wiki.ocf.berkeley.edu',
        'hello.ocf.berkeley.edu', 'dev-hello.ocf.berkeley.edu',
        'staff.ocf.berkeley.edu', 'dev-staff.ocf.berkeley.edu',
      ],
      access_log          => '/var/log/nginx/www-access.log vhost',
      error_log           => '/var/log/nginx/www-error.log';

    'shorturl-ssl':
      server_name => ['ocf.io', 'dev-ocf-io.ocf.berkeley.edu', 'www.ocf.io'],
      add_header  => {
        'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains; preload',
      },
      access_log  => '/var/log/nginx/shorturl-access.log vhost',
      error_log   => '/var/log/nginx/shorturl-error.log';

    'unavailable-ssl':
      server_name         => ['unavailable.ocf.berkeley.edu'],
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      proxy_set_header    => [
        'Host unavailable.ocf.berkeley.edu',
        'X-Forwarded-For $remote_addr',
        'X-Forwarded-Proto $scheme',
        'X-Real-IP $remote_addr',
      ],
      access_log          => '/var/log/nginx/unavailable-access.log vhost';
  }

  # HTTP redirects
  $shorturl_canonical = $::host_env ? {
    'dev'  => 'dev-ocf-io.ocf.berkeley.edu',
    'prod' => 'ocf.io',
  }

  nginx::resource::server {
    'www-http-redirect':
      server_name       => [
        'www.ocf.berkeley.edu', 'www',
        'dev-www', 'dev-www.ocf.berkeley.edu',
        'ocf.berkeley.edu', 'dev-ocf.berkeley.edu',
        'secure', 'secure.ocf.berkeley.edu',
        'ocf.asuc.org', 'death.berkeley.edu', 'linux.berkeley.edu',
        'accounts.ocf.berkeley.edu', 'dev-accounts', 'dev-accounts.ocf.berkeley.edu', 'accounts',
        'wiki.ocf.berkeley.edu', 'dev-wiki', 'dev-wiki.ocf.berkeley.edu', 'wiki',
        'hello.ocf.berkeley.edu', 'dev-hello', 'dev-hello.ocf.berkeley.edu', 'hello',
        'staff.ocf.berkeley.edu', 'dev-staff.ocf.berkeley.edu',
        $::hostname, $::fqdn,
      ],
      listen_port       => $http_port,
      server_cfg_append => {
        'return' => "301 https://${www_canonical}\$request_uri",
      };

    'shorturl-http-redirect':
      server_name       => ['ocf.io', 'dev-ocf-io.ocf.berkeley.edu', 'www.ocf.io'],
      listen_port       => $http_port,
      server_cfg_append => {
        'return' => "301 https://${shorturl_canonical}\$request_uri",
      };

    'unavailable-http':
      server_name         => ['unavailable.ocf.berkeley.edu'],
      listen_port         => $http_port,
      listen_options      => 'default_server',
      ipv6_listen_options => 'default_server',
      proxy               => $backend,
      proxy_set_header    => [
        'Host unavailable.ocf.berkeley.edu',
        'X-Forwarded-For $remote_addr',
        'X-Real-IP $remote_addr',
      ];
  }

  # seed empty config so nginx starts before build-vhosts runs
  file { '/etc/nginx/ocf-vhost.conf':
    ensure  => file,
    content => "# Generated by build-vhosts\n",
    replace => false,
  } ~> Class['Nginx::Service']
}
