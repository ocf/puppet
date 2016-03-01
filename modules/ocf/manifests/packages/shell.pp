class ocf::packages::shell {
  package { ['bash', 'tcsh', 'zsh']: }

  file {
    '/etc/bash.bashrc':
      source => 'puppet:///modules/ocf/shell/bash.bashrc',
      require => Package['bash'];
    '/etc/csh.cshrc':
      source => 'puppet:///modules/ocf/shell/csh.cshrc',
      require => Package['tcsh'];
    '/etc/zsh/zshenv':
      source  => 'puppet:///modules/ocf/shell/zshenv',
      require => Package['zsh'];
    '/etc/zsh/zshrc':
      source  => 'puppet:///modules/ocf/shell/zshrc',
      require => Package['zsh'];
  }
}
