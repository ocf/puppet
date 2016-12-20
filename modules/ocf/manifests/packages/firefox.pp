class ocf::packages::firefox {
  class { 'ocf::packages::firefox::apt':
    stage => first,
  }

  if $::lsbdistcodename == 'jessie' {
    package { 'firefox':
      ensure => present;
    }
  } else {
    # TODO: switch to mozilla.debian.net once they support stretch.
    ocf::repackage { 'firefox':
      backport_on => $::lsbdistcodename,
      dist        => 'experimental',
    }
  }

  # TODO: remove after upgrade to stretch.
  package {
    'iceweasel':
      ensure => absent;
  }

  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/firefox/prefs.js':
      content => template('ocf/firefox/prefs.js.erb'),
      require => Package['firefox'];
    # TODO: start maximized by default
  }
}
