# Include VS Code apt repo.
class ocf::packages::vscode::apt {
  apt::keyring { 'vscode.asc':
    source => 'https://packages.microsoft.com/keys/microsoft.asc',
  }

  apt::source { 'vscode':
    architecture => 'amd64',
    location     => 'http://packages.microsoft.com/repos/vscode',
    release      => 'stable',
    repos        => 'main',
    keyring      => '/etc/apt/keyrings/vscode.asc',
    require      => Apt::Keyring['vscode.asc'],
  }
}
