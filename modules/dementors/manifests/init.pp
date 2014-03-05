class dementors {
  package {
    ['python3', 'apache2', 'apache2-mpm-prefork', 'libapache2-mod-php5',
     'php5-mcrypt', 'mysql-server', 'pssh']:;
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
    '/etc/ssl/stats/ca/ca.key':
      owner => root,
      group => root,
      mode => 400,
      source => 'puppet:///private/stats/ca.key';
    '/etc/ssl/stats/ca/ca.crt':
      owner => root,
      group => root,
      mode => 444,
      source => 'puppet:///private/stats/ca.crt';
    '/etc/ssl/stats/ca/create-cert.sh':
      source => 'puppet:///modules/dementors/ca/create-cert.sh',
      owner => root,
      group => root,
      mode => 755;
    '/etc/ssl/private/stats.crt':
      ensure => link,
      links => manage,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.crt';
    '/etc/ssl/private/stats.key':
      ensure => link,
      links => manage,
      target => '/etc/ssl/stats/ca/certs/stats.ocf.berkeley.edu/stats.ocf.berkeley.edu.key';
  }

  # apache
  file {
    '/etc/apache2/ports.conf':
      owner => root,
      group => root,
      mode => 644,
      require => Package['apache2'],
      notify => Exec["apache-reload"],
      source => 'puppet:///modules/dementors/apache/ports.conf';
    '/etc/apache2/sites-available/stats.ocf.berkeley.edu':
      owner => root,
      group => root,
      mode => 644,
      require => Package['apache2'],
      notify => Exec["apache-reload"],
      source => 'puppet:///modules/dementors/apache/stats.ocf.berkeley.edu';
  }

  exec {
    "apache-reload":
      command => "/usr/sbin/service apache2 reload",
      refreshonly => true;
    "/usr/sbin/a2dissite default":
      onlyif => "/bin/readlink -e /etc/apache2/sites-enabled/default",
      notify => Exec["apache-reload"],
      require => Package["apache2"];
    "/usr/sbin/a2ensite stats.ocf.berkeley.edu":
      unless => "/bin/readlink -e /etc/apache2/sites-enabled/stats.ocf.berkeley.edu",
      notify => Exec["apache-reload"],
      require => [
        Package["apache2"],
        File["/etc/apache2/sites-available/stats.ocf.berkeley.edu"]
      ];
  }
}
