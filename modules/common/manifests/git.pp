class common::git {
  ocf::repackage { 'git':
    backports => true
  }

  file { '/etc/gitconfig':
    source  => 'puppet:///modules/common/gitconfig',
    require => Ocf::Repackage['git'],
  }
}
