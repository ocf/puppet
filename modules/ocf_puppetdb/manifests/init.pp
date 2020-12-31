class ocf_puppetdb {
  class { 'puppetdb':
    database_host       => 'postgres',
    database_username   => 'ocfpuppetdb',
    database_password   => hiera('puppetdb::postgres_password'),
    database_name       => 'ocfpuppetdb',
    jdbc_ssl_properties => '?ssl=true',

    java_args           => {
      '-Xmx' => '1g',
      '-Xms' => '256m',
    },
    manage_firewall     => true,
    ssl_set_cert_paths  => true,
    manage_package_repo => false,
  }

  # firewall input, allow access to ports 8081, the puppet DB port
  ocf::firewall::firewall46 {
    '101 allow puppet DB port':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 8081,
        action => 'accept',
      };
  }
}
