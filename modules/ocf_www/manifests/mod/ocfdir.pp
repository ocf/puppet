class ocf_www::mod::ocfdir {
  package { 'libapache2-mod-ocfdir':; }

  apache::mod { 'ocfdir':
    require => Package['libapache2-mod-ocfdir'];
  }
}
