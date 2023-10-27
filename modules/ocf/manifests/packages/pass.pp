class ocf::packages::pass {
  class { 'ocf::packages::pass::apt':
    stage => first,
  }

  package { 'pass':; }
}
