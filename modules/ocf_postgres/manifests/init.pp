class ocf_postgres {
  class { 'postgresql::server':
    postgres_password => hiera('postgres::root'),
    #                      type    db       usr srcaddr   auth
    ipv4acls          => ['hostssl sameuser all 0.0.0.0/0 md5'],
    ipv6acls          => ['hostssl sameuser all ::/0 md5'];
  }

  # defaults to localhost
  postgresql::server::config_entry { 'listen_addresses':
    value => '*';
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
}
