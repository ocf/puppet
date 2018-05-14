class ocf_docker {
  include ocf::firewall::allow_web
  include ocf::packages::docker
  require ocf_ssl::default_bundle

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,
  }

  nginx::resource::upstream { 'docker-registry':
    members => ['127.0.0.1:5000'];
  }

  # Docker registries currently must be entirely unauthenticated (including
  # write access), or entirely authenticated (including read access).
  #
  # What we want is that anyone can read, but writing requires authentication.
  # To do this we set up two vhosts:
  #   * docker.ocf: a read-only vhost that needs no auth.
  #     We make this work by rejecting non-read-only HTTP verbs
  #   * docker-push.ocf: a read-write vhost that needs auth.
  #
  # Jenkins should push to docker-push.ocf and others should pull from
  # docker.ocf.
  nginx::resource::server {
    default:
      listen_port       => 443,

      ssl               => true,
      ssl_cert          => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key           => "/etc/ssl/private/${::fqdn}.key",
      ssl_dhparam       => '/etc/ssl/dhparam.pem',

      add_header        => {
        'Strict-Transport-Security' => 'max-age=31536000',
      },

      proxy             => 'http://docker-registry',
      proxy_set_header  => [
        'X-Forwarded-Proto $scheme',
        'X-Forwarded-For $proxy_add_x_forwarded_for',
        'Host $http_host'
      ],

      server_cfg_append => {
        # Enable large uploads/downloads
        # https://docs.docker.com/registry/recipes/nginx/
        'chunked_transfer_encoding' => 'on',
        'client_max_body_size'      => 0,
      };

    'docker-ro':
      server_name         => ['docker.ocf.berkeley.edu', 'docker', $::hostname, $::fqdn],

      location_cfg_append => {
        # The `auth_required` is not needed, it's a hack so that the Puppet
        # module doesn't append a semicolon to the end of the limit_except block.
        'limit_except GET HEAD OPTIONS { deny all; } auth_basic' => 'off',
      };

    'docker-push':
      server_name         => ['docker-push.ocf.berkeley.edu'],

      location_cfg_append => {
        'auth_basic'           => 'Restricted',
        'auth_basic_user_file' => '/opt/share/docker.htpasswd',
      },

      raw_append          => [
        'location /_ping { auth_basic off; }',
        'location /v1/_ping { auth_basic off; }',
      ],

      require             => File['/opt/share/docker.htpasswd'],
      subscribe           => File['/opt/share/docker.htpasswd'];
  }

  file {
    '/var/lib/registry':
      ensure    => directory;

    '/opt/share/docker.htpasswd':
      owner     => 'www-data',
      source    => 'puppet:///private/htpasswd',
      mode      => '0400',
      show_diff => false,
      require   => Package['nginx'];
  }

  ocf::systemd::service { 'docker-registry':
    source  => 'puppet:///modules/ocf_docker/docker-registry.service',
    require => [
      Package['docker-ce'],
      File['/var/lib/registry'],
    ],
  }
}
