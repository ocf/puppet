class ocf::packages::git {
  package { ['git', 'gitk', 'git-gui', 'git-svn']:; }

  file { '/etc/gitconfig':
    source  => 'puppet:///modules/ocf/gitconfig',
    require => Package['git'],
  }
}
