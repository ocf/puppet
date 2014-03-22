class fallingrocks::apache {
  package {
    ["apache2"]:;
  }

  file {
    '/etc/apache2/sites-available/mirrors.ocf.berkeley.edu':
      owner => root,
      group => root,
      mode => 644,
      require => Package['apache2'],
      notify => Exec["apache-reload"],
      source => 'puppet:///modules/fallingrocks/mirrors.ocf.berkeley.edu';
  }

  exec {
    "apache-reload":
      command => "/usr/sbin/service apache2 reload",
      refreshonly => true;
    "/usr/sbin/a2dissite 000-default":
      onlyif => "/bin/readlink -e /etc/apache2/sites-enabled/000-default",
      notify => Exec["apache-reload"],
      require => Package["apache2"];
    "/usr/sbin/a2ensite mirrors.ocf.berkeley.edu":
      unless => "/bin/readlink -e /etc/apache2/sites-enabled/mirrors.ocf.berkeley.edu",
      notify => Exec["apache-reload"],
      require => [
        Package["apache2"],
        File["/etc/apache2/sites-available/mirrors.ocf.berkeley.edu"]
      ];
  }
}
