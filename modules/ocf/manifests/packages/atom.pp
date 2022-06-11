class ocf::packages::atom {
  class { 'ocf::packages::atom::apt':
    stage => first,
  }

  package { 'atom':; }
}
