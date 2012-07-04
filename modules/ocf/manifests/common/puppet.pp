class ocf::common::puppet {

  package { 'puppet': }

  file {
    # enable puppet agent, reporting to master, and listen for triggers
    '/etc/default/puppet':
      source  => 'puppet:///modules/ocf/common/puppet/puppetd',
      require => File['/etc/puppet/namespaceauth.conf'];
    # allow puppet master to trigger runs
    '/etc/puppet/auth.conf':
      source  => 'puppet:///modules/ocf/common/puppet/auth.conf';
    # file must exist for puppet 2.6.x agent to start listening
    '/etc/puppet/namespaceauth.conf':
      content => 'file must exist for puppet 2.6.x agent to start listening'
  }

  service { 'puppet':
    subscribe => File['/etc/default/puppet'],
    require   => Package['puppet']
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
