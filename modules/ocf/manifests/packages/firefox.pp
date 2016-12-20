class ocf::packages::firefox {
  class { 'ocf::packages::firefox::apt':
    stage => first,
  }

  $firefox_pkg = $::lsbdistcodename ? {
    'jessie' => 'firefox',
    default  => 'firefox-esr',
  }

  package {
    $firefox_pkg:
      ensure => present;
    'iceweasel':
      ensure => absent;
  }

  file {
    # disable caching, history, blacklisting, and set homepage
    "/etc/${firefox_pkg}/prefs.js":
      content => template('ocf/firefox/prefs.js.erb'),
      require => Package[$firefox_pkg];
    # TODO: start maximized by default
  }
}
