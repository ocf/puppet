define ocf::repackage(
    $package     = $title,
    $recommends  = true,
    $backport_on = undef,
    $dist        = $::lsbdistcodename,
  ) {
  $install_options = $recommends ? {
    true    => ['--no-install-recommends'],
    default => []
  }

  if $backport_on and $dist == $backport_on {
    apt::pin { "bpo-${package}":
      release  => "${dist}-backports",
      priority => 600,
      packages => [$package];
    }

    package { $package:
      # in case the non-backported package is already present
      ensure          => latest,

      # even though we've pinned the package, we still need -t dist-backports
      # so that dependencies don't hold it back
      install_options => concat($install_options, ['-t', "${dist}-backports"]),
      require         => Apt::Pin["bpo-${package}"];
    }
  } else {
    package { $package:
      install_options => $install_options;
    }

    apt::pin { "bpo-${package}":
      ensure => absent;
    }
  }
}
