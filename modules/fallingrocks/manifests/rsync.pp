class fallingrocks::rsync {
  service { "rsync":
    subscribe => File["/etc/rsyncd.conf"],
    require   => Package["rsync"];
  }

  file {
    "/etc/rsyncd.conf":
      source  => "puppet:///modules/fallingrocks/rsyncd.conf",
      require => Package["rsync"];
  }
}
