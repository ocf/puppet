class common::zsh {
  file { '/etc/zsh/zshenv':
    source  => 'puppet:///modules/common/zsh/zshenv'
  }
  file { '/etc/zsh/zshrc':
    source  => 'puppet:///modules/common/zsh/zshrc'
  }
}
