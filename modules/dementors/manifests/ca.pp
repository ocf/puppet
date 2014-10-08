class dementors::ca {
  file {
    '/etc/ssl/stats':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    '/etc/ssl/stats/ca':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    '/etc/ssl/stats/ca/certs':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    '/etc/ssl/stats/ca/crl':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0755';
    '/etc/ssl/stats/ca/openssl.cnf':
      source => 'puppet:///modules/dementors/ca/openssl.cnf',
      owner  => root,
      group  => root,
      mode   => '0644';
    '/etc/ssl/stats/ca/ca.key':
      owner  => root,
      group  => root,
      mode   => '0400',
      source => 'puppet:///private/stats/ca.key';
    '/etc/ssl/stats/ca/ca.crt':
      owner  => root,
      group  => root,
      mode   => '0444',
      source => 'puppet:///private/stats/ca.crt';
    '/etc/ssl/stats/ca/create-cert.sh':
      source => 'puppet:///modules/dementors/ca/create-cert.sh',
      owner  => root,
      group  => root,
      mode   => '0755';
    '/etc/ssl/private/stats.crt':
      ensure => link,
      links  => manage,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.crt';
    '/etc/ssl/private/stats.key':
      ensure => link,
      links  => manage,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.key';
  }
}
