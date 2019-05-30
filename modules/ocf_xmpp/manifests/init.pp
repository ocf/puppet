class ocf_xmpp {
  # Needed to connect to MySQL
  package { ['lua-dbi-mysql']: }

  user { 'prosody':
    groups  => 'ssl-cert',
    require => [Package['prosody'], Package['ssl-cert']],
  }

  ocf::firewall::firewall46 {
    '101 allow xmpp':
      opts   => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => [5222, 5269],
        action => 'accept',
      }
  };

  $vhost_name = $::host_env ? {
    'dev'  => 'dev-xmpp.ocf.berkeley.edu',
    'prod' => 'ocf.berkeley.edu',
  }

  class { 'prosody':
    modules                => [
      'register',
    ],

    # Might want to change this depending on how we want registration to work
    allow_registration     => false,

    ssl_key                => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert               => "/etc/ssl/private/${::fqdn}.bundle",

    c2s_require_encryption => true,

    authentication         => internal_hashed,
    storage                => sql,

    sql                    => {
      driver   => 'MySQL',
      database => 'prosody',
      host     => 'mysql',
      port     => 3306,
      username => 'prosody',
      password => lookup('xmpp::prosody_mysql_password'),
    },
  }

  prosody::virtualhost {
    $vhost_name:
      ensure   => present,
      ssl_key  => "/etc/ssl/private/${::fqdn}.key",
      ssl_cert => "/etc/ssl/private/${::fqdn}.bundle",
  }
}
