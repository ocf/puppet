class ocf::packages::firefox {
  package {
    'firefox':
      ensure => present;
    'iceweasel':
      ensure => absent;
  }

  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/firefox/profile/prefs.js':
      content => template('ocf_desktop/firefox/prefs.js.erb'),
      require => Package['firefox'];
    # start maximized by default
    '/etc/firefox/profile/localstore.rdf':
      source  => 'puppet:///modules/ocf_desktop/firefox/localstore.rdf',
      require => Package['firefox']
  }
}
