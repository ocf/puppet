class ocf::packages::custom::apt ($sources = [], $stage = 'first') {
  $sources.each |$source| {
    apt::key { $source['name']:
      id     => $source['keyid'],
      server => 'pgp.ocf.berkeley.edu',
    }

    $real_release = $source['release'] ? {
      # default to current release name (e.g. stretch)
      undef   => $::lsbdistcodename,
      default => $source['release'],
    }
    $real_repos = $source['repos'] ? {
      # default to 'main'
      undef   => 'main',
      default => $source['repos'],
    }

    apt::source { $source['name']:
      architecture => 'amd64',
      location     => $source['location'],
      release      => $real_release,
      repos        => $real_repos,
      require      => Apt::Key[$source['name']],
    }
  }
}
