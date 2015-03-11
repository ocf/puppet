class ocf_stats::ca {
  file {
    ['/etc/ssl/stats', '/etc/ssl/stats/ca', '/etc/ssl/stats/ca/certs', '/etc/ssl/stats/ca/crl']:
      ensure => directory,
      mode   => '0755';

    '/etc/ssl/stats/ca/openssl.cnf':
      source => 'puppet:///modules/ocf_stats/ca/openssl.cnf',
      mode   => '0644';

    '/etc/ssl/stats/ca/ca.key':
      mode   => '0400',
      source => 'puppet:///private/stats/ca.key';

    '/etc/ssl/stats/ca/ca.crt':
      mode   => '0444',
      source => 'puppet:///private/stats/ca.crt';

    '/etc/ssl/stats/ca/create-cert.sh':
      source => 'puppet:///modules/ocf_stats/ca/create-cert.sh',
      mode   => '0755';

    '/etc/ssl/private/stats.crt':
      ensure => link,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.crt';

    '/etc/ssl/private/stats.key':
      ensure => link,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.key';
  }
}
