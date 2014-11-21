class ocf_puppet {
  include common::ldapvi
  include ocf_ssl

  include apt_dater
  include puppetmaster

  class { 'apache':
    default_vhost => false;
  }

  include apache::mod::cgid

  apache::vhost { 'puppet public':
    servername => 'puppet.ocf.berkeley.edu',
    port       => 443,
    docroot    => '/var/www',

    ssl        => true,
    ssl_key    => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert   => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain  => '/etc/ssl/certs/incommon-intermediate.crt',

    directories => [{
      path        => '/var/www',
      options     => ['ExecCGI'],
      addhandlers => [{
        handler    => 'cgi-script',
        extensions => ['.cgi']
      }]
    }];
  }

  file {
    '/var/www/webhook':
      ensure  => directory,
      owner   => www-data,
      group   => www-data,
      mode    => '0755',
      source  => 'puppet:///modules/ocf_puppet/webhook',
      recurse => true;
  }
}
