class fallingrocks {
  # mirroring user
  user { "mirrors":
    comment => "OCF Mirroring",
    home    => "/opt/mirrors",
    groups  => ["sys"],
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
    "/opt/mirrors/etc":
      ensure  => directory,
      mode    => 755;
  }

  # SSL certificates
  file {
    # key and cert
    "/etc/ssl/private/mirrors.ocf.berkeley.edu.key":
      owner  => root,
      group  => root,
      mode   => 400,
      source => "puppet:///private/mirrors.ocf.berkeley.edu.key";
    "/etc/ssl/private/mirrors.ocf.berkeley.edu.crt":
      owner  => root,
      group  => root,
      mode   => 444,
      source => "puppet:///private/mirrors.ocf.berkeley.edu.crt";

    # certificate chain
    "/etc/ssl/private/incommon.crt":
      owner  => root,
      group  => root,
      mode   => 444,
      source => "puppet:///private/incommon.crt";

    # combined key + cert + chain
    "/etc/ssl/private/mirrors.ocf.berkeley.edu.pem":
      owner  => root,
      group  => root,
      mode   => 400,
      source => "puppet:///private/mirrors.ocf.berkeley.edu.pem";
  }
}
