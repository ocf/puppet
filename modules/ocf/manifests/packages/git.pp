class ocf::packages::git {
  ocf::repackage { ['git', 'gitk', 'git-gui', 'git-svn']:
    backport_on => 'wheezy';
  }

  file { '/etc/gitconfig':
    source  => 'puppet:///modules/ocf/gitconfig',
    require => Ocf::Repackage['git'],
  }
}
