class dementors::apache {
  package {
    ['apache2', 'apache2-mpm-prefork', 'libapache2-mod-php5', 'php5-mcrypt' ]:;
  }
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
    "/usr/sbin/a2dissite 000-default":
      onlyif => "/bin/readlink -e /etc/apache2/sites-enabled/000-default",
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
