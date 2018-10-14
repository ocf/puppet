# Include VS Code apt repo.
class ocf::packages::vscode::apt {
  apt::key { 'vscode':
    id     => 'BC528686B50D79E339D3721CEB3E94ADBE1229CF',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'vscode':
    architecture => 'amd64',
    location     => 'http://packages.microsoft.com/repos/vscode',
    release      => 'stable',
    repos        => 'main',
    require      => Apt::Key['vscode'],
  }
}
