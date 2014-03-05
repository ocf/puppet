class dementors {
  package {
    ['python3', 'apache2-mpm-prefork', 'libapache2-mod-php5', 'php5-mcrypt',
    'mysql-server', 'pssh']:;
  }

  user {
    'ocfstats':
      comment => 'OCF Desktop Stats',
      home => '/opt/stats',
      system => true,
      groups => 'sys';
  }

  file {
    '/opt/stats':
      ensure => directory,
      owner => ocfstats,
      group => ocfstaff,
      mode => 775,
      require => User['ocfstats'];
    '/opt/stats/cgi':
      ensure => directory,
      owner => ocfstats,
      group => ocfstaff,
      mode => 775;
    '/opt/stats/desktop_list':
      owner => ocfstats,
      group => ocfstaff,
      mode => 444,
      source => 'puppet:///contrib/desktop/desktop_list';
    '/opt/stats/id_rsa':
      owner => ocfstats,
      group => root,
      mode => 400,
      source => 'puppet:///private/stats/id_rsa';
    '/opt/stats/id_rsa.pub':
      owner => ocfstats,
      group => ocfstaff,
      mode => 444,
      source => 'puppet:///modules/dementors/stats/id_rsa.pub';

    # certificate authority
    '/etc/ssl/stats':
      ensure => directory,
      owner => root,
      group => root,
      mode => 755;
    '/etc/ssl/stats/ca':
      ensure => directory,
      owner => root,
      group => root,
      mode => 755;
    '/etc/ssl/stats/ca/certs':
      ensure => directory,
      owner => root,
      group => root,
      mode => 755;
    '/etc/ssl/stats/ca/crl':
      ensure => directory,
      owner => root,
      group => root,
      mode => 755;
    '/etc/ssl/stats/ca/openssl.cnf':
      source => 'puppet:///modules/dementors/ca/openssl.cnf',
      owner => root,
      group => root,
      mode => 644;
  }
}
