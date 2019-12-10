class ocf::packages::firefox {
  $browser_homepage = lookup('browser_homepage')

  package { 'firefox-esr':; }

  file {
    # disable caching, history, blacklisting, set homepage, and other options.
    '/etc/firefox-esr/firefox-esr.js':
      content => template('ocf/firefox/prefs.js.erb'),
      require => Package['firefox-esr'];
    # TODO: start maximized by default
  }
}
