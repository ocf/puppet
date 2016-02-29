class ocf_ssh::webssh {
  package { ['shellinabox']:; }

  case $::hostname {
    tsunami: { $webssh_fqdn = 'ssh.ocf.berkeley.edu' }
    default: { $webssh_fqdn = 'dev-ssh.ocf.berkeley.edu' }
  }

  class { 'nginx':
    # if we let nginx manage its own repo, it uses the `apt` module; this
    # creates an unresolvable dependency cycle because we declare class `apt`
    # in stage first (and we're currently in stage main)
    manage_repo => false;
  }

  nginx::resource::upstream { 'webssh':
    members => ['localhost:4200'];
  }

  nginx::resource::vhost {
    $webssh_fqdn:
      server_name => [
        $webssh_fqdn
      ],

      proxy => 'http://webssh',

      ssl        => true,
      ssl_cert   => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key    => "/etc/ssl/private/${::fqdn}.key",

      add_header => {
        'Strict-Transport-Security' => 'max-age=31536000',
      },

      rewrite_to_https => true;
  }
}
