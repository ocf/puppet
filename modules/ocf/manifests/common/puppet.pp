class ocf::common::puppet {

  # provide puppet config
  file { '/etc/default/puppet':
    source => 'puppet:///modules/ocf/common/puppetd'
  }

  # create share directories
  file {
    '/opt/share':
      ensure => directory;
    '/opt/share/puppet':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false
  }

  # install augeas-tools
  package { 'augeas-tools': }

}
