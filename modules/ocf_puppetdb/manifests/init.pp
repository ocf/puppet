class ocf_puppetdb {
  include ocf_ssl::default_bundle

  class { 'puppetdb::database::postgresql':
    # Only listen locally since puppetdb is the only database client and it is
    # a local database
    listen_addresses    => 'localhost',

    # We can't have postgresql manage the package repo, since it tries to
    # include the ::apt class that we have already included ourselves with
    # custom options, which causes duplicate declaration errors. Besides,
    # we'd rather install from Debian package repos anyway instead of
    # PostgreSQL upstream repos.
    manage_package_repo => false,

    # Although 9.6 is the default currently, we want to pin this so that later
    # version bumps do not change this and we can keep installing whichever
    # version is available in Debian repos
    postgres_version    => '9.6',
  }

  class { 'puppetdb::server':
    database_host      => 'localhost',
    java_args          => {
      '-Xmx' => '1g',
      '-Xms' => '256m',
    },
    manage_firewall    => true,
    ssl_set_cert_paths => true,
  }

  # firewall input, allow access to ports 8081
  ocf::firewall::firewall46 {
    '101 allow access to port 8081':
      opts => {
        'chain'  => 'PUPPET-INPUT',
        'proto'  => 'all',
        'action' => 'accept',
        'dport'  => 8081,
      };
  }
}
