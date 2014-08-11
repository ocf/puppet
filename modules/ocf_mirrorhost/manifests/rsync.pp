class ocf_mirrorhost::rsync {
  service { "rsync":
    subscribe => File["/etc/rsyncd.conf"],
    require   => Package["rsync"];
  }

  file {
    "/etc/rsyncd.conf":
      source  => "puppet:///modules/ocf_mirrorhost/rsyncd.conf",
      require => Package["rsync"];
  }
}
