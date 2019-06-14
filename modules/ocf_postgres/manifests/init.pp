class ocf_postgres {
  class { 'ocf::ssl::default':
    owner => 'root',
  }

  class { 'postgresql::server':
    postgres_password => lookup('postgres::rootpw'),
    # https://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html
    ipv4acls          => ['hostssl sameuser all 0.0.0.0/0 md5'],
    ipv6acls          => ['hostssl sameuser all ::/0 md5'],
  }

  postgresql::server::config_entry {
    # defaults to localhost
    'listen_addresses':
      value => '*';
    'ssl':
      value => 'on';
    'ssl_cert_file':
      value => "/etc/ssl/private/${::fqdn}.bundle";
    'ssl_key_file':
      value => "/etc/ssl/private/${::fqdn}.key";
  }

  ocf::firewall::firewall46 {
    '101 allow postgresql':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp'],
        dport  => 5432,
        action => 'accept',
      };
  }

  # Postgres expects the letsencrypt certs to be owned by root
  # The renewal script expects the letsencrypt certs to be owned by ocfletsencrypt
  # We change the owner to ocfletsencrypt before the renewal script runs
  # Then we change the owner back to root after it runs
  exec { 'chown-letsencrypt':
    command => 'chown -R ocfletsencrypt:ssl-cert /var/lib/lets-encrypt/certs',
    before  => Class['Ocf::Ssl::Default'],
  }

  exec { 'chown-root':
    command => 'chown -R root:ssl-cert /var/lib/lets-encrypt/certs',
    require => Class['Ocf::Ssl::Default'],
  }

  Class['Ocf::Ssl::Default'] ~> Class['Postgresql::Server']

  file {
    # copies proper .pgpass file for ocfbackups to authenticate on backup
    '/opt/share/.pgpass':
      source    => 'puppet:///private/pgpass',
      mode      => '0600',
      owner     => 'ocfbackups',
      show_diff => false;
  }

}
