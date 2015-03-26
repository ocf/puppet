class ocf_desktop::iceweasel {

  # install iceweasel from backports and spellcheck dictionary
  ocf::repackage { 'iceweasel':
    backports => true
  }
  package { 'hunspell-en-us': }

  file {
    # disable caching, history, blacklisting, and set homepage
    '/etc/iceweasel/profile/prefs.js':
      source  => 'puppet:///modules/ocf_desktop/iceweasel/prefs.js',
      require => Ocf::Repackage['iceweasel'];
    # start maximized by default
    '/etc/iceweasel/profile/localstore.rdf':
      source  => 'puppet:///modules/ocf_desktop/iceweasel/localstore.rdf',
      require => Ocf::Repackage['iceweasel']
  }

}
