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
      ensure => directory,
      backup => false,
      purge  => true,
      force  => true
  }

  # install augeas-tools
  package { 'augeas-tools': }

}
