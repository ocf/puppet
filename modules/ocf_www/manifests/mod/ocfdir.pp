class ocf_www::mod::ocfdir {
  # TODO: Figure out what to do here for stretch (this package isn't included
  # and has been patched for OCF use)
  package { 'libapache2-mod-ocfdir':; }

  apache::mod { 'ocfdir':
    require => Package['libapache2-mod-ocfdir'];
  }
}
