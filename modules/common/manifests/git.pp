class common::git {
  package { 'git': }
  file { '/etc/gitconfig':
    source  => 'puppet:///modules/common/gitconfig',
    require => Package['git'],
  }
}
