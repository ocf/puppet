class ocf::packages::brave {
  class { 'ocf::packages::brave::apt':
    stage =>  first,
  }

  package { 'brave':; }
}
