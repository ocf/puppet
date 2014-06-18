class fallingrocks::ftpsync {
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
    "/opt/mirrors/bin":
      ensure  => link,
      links   => manage,
      target  => "/opt/mirrors/distrib/bin",
      require => Exec["get-ftpsync"];
    "/opt/mirrors/bin/ftpsync-security":
      ensure  => link,
      links   => manage,
      target  => "/opt/mirrors/bin/ftpsync",
      require => File["/opt/mirrors/bin"];
    "/opt/mirrors/etc/ftpsync.conf":
      source  => "puppet:///modules/fallingrocks/ftpsync.conf",
      mode    => 644;
    "/opt/mirrors/etc/ftpsync-security.conf":
      source  => "puppet:///modules/fallingrocks/ftpsync-security.conf",
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

  cron { "ftpsync-security":
    command => "/opt/mirrors/bin/ftpsync-security",
    user    => "mirrors",
    hour    => "*",
    minute  => "16";
  }
}
