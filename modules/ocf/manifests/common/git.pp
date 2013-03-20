class ocf::common::git {
  package { 'git': }
  file { '/etc/gitconfig':
    source  => 'puppet:///modules/ocf/common/gitconfig',
    require => Package['git'],
  }
}
