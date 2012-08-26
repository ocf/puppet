class ocf::common::mount {
  file {
    "/home":
      ensure => directory;
    "/mnt":
      ensure => directory;
    "/services":
      ensure => directory;
  }

  mount { "/home":
    device  => "homes:/symlinks",
    fstype  => "nfs",
    options => "bg,hard,intr,nosuid",
    ensure  => mounted,
    name    => "/home",
  }

  mount { "/mnt":
    device  => "homes:/homes",
    fstype  => "nfs",
    options => "bg,hard,intr,nosuid",
    ensure  => mounted,
    name    => "/mnt",
  }

  mount { "/services":
    device  => "services:/services",
    fstype  => "nfs",
    options => "bg,hard,intr,nosuid",
    ensure  => mounted,
    name    => "/services",
  }
}
