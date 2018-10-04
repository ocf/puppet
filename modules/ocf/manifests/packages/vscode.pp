class ocf::packages::vscode {
  class { 'ocf::packages::vscode::apt':
    stage =>  first,
  }

  package { 'code':; }
}
