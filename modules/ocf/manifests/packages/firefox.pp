class ocf::packages::firefox {
  $browser_homepage = lookup('browser_homepage')

  package { 'firefox-esr':; }

  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/firefox-esr/firefox-esr.js':
      content => template('ocf/firefox/prefs.js.erb'),
      require => Package['firefox-esr'];
    # TODO: start maximized by default

    # TODO: temporary, remove
    '/etc/firefox/':
      ensure => absent,
      force  => true;
  }
}
