class ocf_puppetdb {
  include ocf_ssl::default_bundle

  class { 'puppetdb::database::postgresql':
    # Only listen locally since puppetdb is the only client and it is local
    listen_addresses    => 'localhost',

    # We can't have postgresql manage the package repo, since it tries to
    # include the ::apt class that we have already included ourselves with
    # custom options, which causes duplicate declaration errors. Besides,
    # we'd rather install from Debian package repos anyway.
    manage_package_repo => false,

    # 9.6 is currently the default, but we want to pin this so that later
    # version bumps do not change this and we can keep installing whichever
    # version is available in Debian repos
    postgres_version    => '9.6',
  }

  class { 'puppetdb::server':
    database_host => 'localhost',
    ssl_set_cert_paths => true,
  }
}
