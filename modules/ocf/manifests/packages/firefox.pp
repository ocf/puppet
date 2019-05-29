class ocf::packages::firefox {
  $browser_homepage = lookup('browser_homepage')

  package { 'firefox':; }

  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/firefox/syspref.js':
      content => template('ocf/firefox/prefs.js.erb'),
      require => Package['firefox'];
    # TODO: start maximized by default
  }
}
