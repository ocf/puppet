class ocf::git {
  ocf::repackage { ['git', 'gitk', 'git-gui']:
    backports => true
  }

  file { '/etc/gitconfig':
    source  => 'puppet:///modules/ocf/gitconfig',
    require => Ocf::Repackage['git'],
  }
}
