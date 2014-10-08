class ocf_ssh::webssh {
  package { ['shellinabox']:; }

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
    'ssh.ocf.berkeley.edu':
      server_name => [
        'ssh.ocf.berkeley.edu'
      ],

      proxy => 'http://webssh',

      ssl      => true,
      ssl_cert => "/etc/ssl/private/${::fqdn}.bundle",
      ssl_key  => "/etc/ssl/private/${::fqdn}.key",

      rewrite_to_https => true;
  }
}
