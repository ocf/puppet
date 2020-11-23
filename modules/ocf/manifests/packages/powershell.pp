class ocf::packages::powershell {
  class { 'ocf::packages::powershell::apt':
    stage =>  first,
  }

  package { 'powershell':; }
}
