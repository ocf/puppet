class ocf::packages::brave {
  include ocf::userns

  class { 'ocf::packages::brave::apt':
    stage =>  first,
  }

  package { 'brave':; }
}
