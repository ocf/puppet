class ocf::packages::riot {
  class { 'ocf::packages::riot::apt':
    stage => first,
  }

  package { 'riot-desktop':; }
}
