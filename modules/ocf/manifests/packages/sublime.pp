class ocf::packages::sublime {
  class { 'ocf::packages::sublime::apt':
    stage =>  first,
  }

  package { 'sublime-text':; }
}
