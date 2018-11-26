class ocf_ssh::webssh {
  include ocf::firewall::allow_web

  package { ['shellinabox']:; }
  -> augeas { '/etc/default/shellinabox':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/shellinabox',
    changes => [
      # Only listen on localhost for connections since we are proxying through
      # nginx. Also disable SSL since we are proxying through nginx and due to
      # https://github.com/shellinabox/shellinabox/issues/371
      "set SHELLINABOX_ARGS '\"--no-beep --disable-ssl --localhost-only\"'",
    ],
  }
  ~> service { 'shellinabox':; }

  case $::hostname {
    tsunami: { $webssh_fqdn = 'ssh.ocf.berkeley.edu' }
    default: { $webssh_fqdn = 'dev-ssh.ocf.berkeley.edu' }
  }

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,
  }

  # Restart nginx if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Nginx::Service']

  nginx::resource::upstream { 'webssh':
    members => ['localhost:4200'];
  }

  nginx::resource::server {
    $webssh_fqdn:
      server_name  => [
        $webssh_fqdn
      ],

      proxy        => 'http://webssh',

      ssl          => true,
      ssl_cert     => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key      => "/etc/ssl/private/${::fqdn}.key",

      add_header   => {
        'Strict-Transport-Security' => 'max-age=31536000',
      },

      ssl_redirect => true;
  }
}
