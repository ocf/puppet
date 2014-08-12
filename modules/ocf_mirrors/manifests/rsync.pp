class ocf_mirrors::rsync {
  service { "rsync":
    subscribe => File["/etc/rsyncd.conf"],
    require   => Package["rsync"];
  }

  file {
    "/etc/rsyncd.conf":
      source  => "puppet:///modules/ocf_mirrors/rsyncd.conf",
      require => Package["rsync"];
  }
}
