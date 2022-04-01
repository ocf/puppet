class ocf::packages::chicago {
  class { 'ocf::packages::chicago::apt':
    stage => first,
  }

  package { 'chicago95-theme-all':; }
}
