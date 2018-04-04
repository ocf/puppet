class ocf::packages::shell {
  package { ['bash', 'tcsh', 'zsh', 'fish']: }

  file {
    # Bash system-wide config
    '/etc/bash.bashrc':
      source => 'puppet:///modules/ocf/shell/bash.bashrc',
      require => Package['bash'];
    '/etc/bash.bash_logout':
      source => 'puppet:///modules/ocf/shell/bash.bash_logout',
      require => Package['bash'];

    # C shell system-wide config
    '/etc/csh.cshrc':
      source => 'puppet:///modules/ocf/shell/csh.cshrc',
      require => Package['tcsh'];
    '/etc/csh.logout':
      source => 'puppet:///modules/ocf/shell/csh.logout',
      require => Package['tcsh'];

    # Z shell system-wide config
    '/etc/zsh/zshenv':
      source  => 'puppet:///modules/ocf/shell/zshenv',
      require => Package['zsh'];
    '/etc/zsh/zshrc':
      source  => 'puppet:///modules/ocf/shell/zshrc',
      require => Package['zsh'];
    '/etc/zsh/zlogout':
      source  => 'puppet:///modules/ocf/shell/zlogout',
      require => Package['zsh'];

    # Fish shell system-wide config
    '/etc/fish/config.fish':
      source => 'puppet:///modules/ocf/shell/config.fish',
      require => Package['fish'];

    # termite terminfo
    '/usr/share/terminfo/x/xterm-termite':
      source => 'puppet:///modules/ocf/shell/termite.terminfo',
      notify => Exec['compile-terminfo'];
  }

  exec { 'compile-terminfo':
    command => 'tic -x /usr/share/terminfo/x/xterm-termite',
    refreshonly => true;
  }
}
