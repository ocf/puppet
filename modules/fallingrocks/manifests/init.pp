class fallingrocks {
  # ftpsync debian mirror
  user { "mirrors":
    comment => "OCF Mirroring",
    home    => "/opt/mirrors",
    groups  => ["sys"],
    require => File["/opt/mirrors"];
  }

  exec { "get-ftpsync":
    command => "wget -O - -q http://ftp-master.debian.org/ftpsync.tar.gz | tar xvfz - -C /opt/mirrors",
    user    => "mirrors",
    creates => "/opt/mirrors/distrib",
    require => File["/opt/mirrors"];
  }

  File {
    owner => mirrors,
    group => mirrors
  }

  file {
    "/opt/mirrors":
      ensure  => directory,
      mode    => 755;
    "/opt/mirrors/ftp":
      ensure  => directory,
      mode    => 755;
    "/opt/mirrors/log":
      ensure  => directory,
      mode    => 755;
    "/opt/mirrors/bin":
      ensure  => link,
      links   => manage,
      target  => "/opt/mirrors/distrib/bin",
      require => Exec["get-ftpsync"];
    "/opt/mirrors/etc":
      ensure  => directory,
      mode    => 755;
    "/opt/mirrors/etc/ftpsync.conf":
      source  => "puppet:///modules/fallingrocks/ftpsync.conf",
      mode    => 644;
    "/opt/mirrors/etc/common":
      ensure  => link,
      links   => manage,
      target  => "/opt/mirrors/distrib/etc/common";
  }

  cron { "ftpsync":
    command => "/opt/mirrors/bin/ftpsync",
    user    => "mirrors",
    hour    => "*/4",
    minute  => "42";
  }

  # web access to mirrors
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
