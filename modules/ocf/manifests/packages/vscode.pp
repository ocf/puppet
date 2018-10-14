class ocf::packages::vscode {
  class { 'ocf::packages::vscode::apt':
    stage =>  first,
  }

  package { 'code':; }

  augeas { 'code.desktop Exec':
    lens    => 'Desktop.lns',
    incl    => '/usr/share/applications/code.desktop',
    changes => [
      'set "Desktop Entry/Exec" "/usr/share/code/code --skip-getting-started --unity-launch %F"'
    ],
    onlyif  => [
      'match */Exec not_include --skip-getting-started'
    ]
  }
}
