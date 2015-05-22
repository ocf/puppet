class ocf::git {
  ocf::repackage { ['git', 'gitk', 'git-gui']:
    backport_on => 'wheezy';
  }

  file { '/etc/gitconfig':
    source  => 'puppet:///modules/ocf/gitconfig',
    require => Ocf::Repackage['git'],
  }
}
