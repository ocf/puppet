class ocf_desktop::iceweasel {
  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/iceweasel/profile/prefs.js':
      content => template('ocf_desktop/iceweasel/prefs.js.erb'),
      require => Package['iceweasel'];
    # start maximized by default
    '/etc/iceweasel/profile/localstore.rdf':
      source  => 'puppet:///modules/ocf_desktop/iceweasel/localstore.rdf',
      require => Package['iceweasel']
  }
}
