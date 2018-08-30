class ocf_postgres {
  class { 'postgresql::server':
    postgres_password       => hiera('postgres::root'),
    ip_mask_allow_all_users => '0.0.0.0/0';
  }

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
