class ocf::packages::element {
  class { 'ocf::packages::element::apt':
    stage => first,
  }

  package { 'element-desktop':; }
}
