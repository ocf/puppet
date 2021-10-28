class ocf::packages::brave {
  # Remove the old version of brave
  package { 'brave':
    ensure => purged
  }

  # Remove the new version of brave
  package { 'brave-browser':
    ensure => purged
  }
}
