class ocf::common::puppet {

  # set environment to production
  augeas { '/etc/puppet/puppet.conf':
    context => '/files/etc/puppet/puppet.conf',
    changes => 'set agent/environment production',
    require => Package['augeas-tools','puppet']
  }

  package { 'puppet':
    ensure    => latest,
    require   => Exec['aptitude update']
  }
  exec { 'puppet-fix_bug7680':
    command   => 'sed -i "s/metadata.links == :manage/resource[:links] == :manage/g" /usr/lib/ruby/1.8/puppet/type/file/source.rb',
    subscribe => Package['puppet']
  }

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
    subscribe => [ File['/etc/default/puppet'], Augeas['/etc/puppet/puppet.conf'] ],
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

  # install custom script to display and set puppet environment
  file { '/usr/local/sbin/ocf-puppetenv':
    mode    => '0755',
    source  => 'puppet:///modules/ocf/common/puppet/ocf-puppetenv',
    require => Package['augeas-tools','puppet']
  }

}
