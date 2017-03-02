# In stretch, Debian starting shipping absolutely awful default vim settings
# (mouse mode, etc.). We turn those off.
class ocf::packages::vim {
  package { ['vim', 'vim-nox']:; }

  file { '/etc/vim/vimrc.local':
    source  => 'puppet:///modules/ocf/packages/vim/vimrc.local',
    require => Package['vim', 'vim-nox'],
  }
}
