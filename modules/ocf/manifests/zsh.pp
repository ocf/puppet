class ocf::zsh {
  file {
    '/etc/zsh/zshenv':
      source  => 'puppet:///modules/ocf/zsh/zshenv',
      require => Package['zsh'];
    '/etc/zsh/zshrc':
      source  => 'puppet:///modules/ocf/zsh/zshrc',
      require => Package['zsh'];
  }
}
