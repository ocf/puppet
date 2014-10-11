class lightning {
  class { 'apache':
    default_vhost => false;
  }

  include apache::mod::cgid

  apache::vhost { 'puppet public':
    servername => 'puppet.ocf.berkeley.edu',
    port       => 443,
    docroot    => '/var/www',

    ssl        => true,
    ssl_key    => '/etc/ssl/private/lightning.ocf.berkeley.edu.key',
    ssl_cert   => '/etc/ssl/private/lightning.ocf.berkeley.edu.crt',
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
      source  => 'puppet:///modules/lightning/webhook',
      recurse => true;
  }
}
