class ocf::packages::firefox {
  class { 'ocf::packages::firefox::apt':
    stage => first,
  }

  package {
    'firefox':
      ensure => present;
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
