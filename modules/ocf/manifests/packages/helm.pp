# Include Helm apt repo
class ocf::packages::helm {
  class { 'ocf::packages::helm::apt':
    stage =>  first,
  }

  package { 'helm':; }
}
