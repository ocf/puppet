class lightning {
  class { 'apache':
    default_vhost => false;
  }

  apache::vhost { 'puppet public':
    servername => 'puppet.ocf.berkeley.edu',
    port       => 443,
    docroot    => '/var/www',
    ssl        => true,
    ssl_key    => '/etc/ssl/private/lightning.ocf.berkeley.edu.key',
    ssl_cert   => '/etc/ssl/private/lightning.ocf.berkeley.edu.crt',
    ssl_chain  => '/etc/ssl/certs/incommon-intermediate.crt';
  }
}
