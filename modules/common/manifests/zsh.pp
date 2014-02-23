class common::zsh {
  file {
    '/etc/zsh/zshenv':
      source  => 'puppet:///modules/common/zsh/zshenv',
      require => Package['zsh'];
    '/etc/zsh/zshrc':
      source  => 'puppet:///modules/common/zsh/zshrc',
      require => Package['zsh'];
  }
}
