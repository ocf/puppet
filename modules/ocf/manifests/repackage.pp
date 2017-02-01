define ocf::repackage(
    $package     = $title,
    $recommends  = true,
    $backport_on = [],
    $dist        = "${::lsbdistcodename}-backports",
  ) {
  $install_options = $recommends ? {
    false   => ['--no-install-recommends'],
    default => []
  }

  if member(any2array($backport_on), $::lsbdistcodename) {
    # We can't pin packages, because it won't install required dependencies that
    # way, so we instead upgrade the package once (as long as it isn't a
    # backport version already), and then future upgrades are done the normal
    # way with apt-dater. It would be best if apt-dater did everything,
    # including the original upgrade, but then a package and all its
    # dependencies would need to be pinned, which is excessive and prone to
    # breaking if a package's dependencies change.
    exec { "apt install ${package}":
      command => "/usr/bin/apt-get -y -o Dpkg::Options::=--force-confold ${install_options[0]} -t ${dist} install ${package}",
      logoutput   => on_failure,
      environment => [
        'DEBIAN_FRONTEND=noninteractive',
      ],
      unless      => "/usr/bin/apt-cache policy ${package} | grep -A1 \\* | grep -w ${dist}",
      before      => Package[$package];
    }
  }

  package { $package:
    install_options => $install_options;
  }
}
