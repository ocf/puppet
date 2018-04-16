class ocf_ssh::webssh {
  package { ['shellinabox']:; }

  case $::hostname {
    tsunami: { $webssh_fqdn = 'ssh.ocf.berkeley.edu' }
    default: { $webssh_fqdn = 'dev-ssh.ocf.berkeley.edu' }
  }

  class { 'nginx':
    manage_repo  => false,
    confd_purge  => true,
    server_purge => true,
  }

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
