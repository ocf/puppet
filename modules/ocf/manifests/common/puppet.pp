class ocf::common::puppet {

  # set environment to production
  augeas { '/etc/puppet/puppet.conf':
    context => '/files/etc/puppet/puppet.conf',
    changes => 'set agent/environment production',
    require => Package['augeas-tools','puppet'],
    notify  => Service['puppet'],
  }

  package { 'puppet':
    ensure      => latest,
    require     => Exec['aptitude update']
  }
  exec { 'puppet-fix_bug7680':
    command     => 'sed -i "s/metadata.links == :manage/resource[:links] == :manage/g" /usr/lib/ruby/1.8/puppet/type/file/source.rb',
    refreshonly => true,
    subscribe   => Package['puppet']
  }

  # enable puppet agent and reporting to master
  file { '/etc/default/puppet':
    source => 'puppet:///modules/ocf/common/puppet/puppetd',
    notify => Service['puppet'],
  }

  service { 'puppet':
    require   => Package['puppet'],
  }

  # create share directories
  file {
    '/opt/share':
      ensure => directory,
    ;
    '/opt/share/puppet':
      ensure  => directory,
      recurse => true,
      purge   => true,
      force   => true,
      backup  => false,
    ;
  }

  # install augeas-tools
  package { 'augeas-tools': }

  # install custom script to display and set puppet environment
  file { '/usr/local/sbin/ocf-puppetenv':
    mode    => '0755',
    source  => 'puppet:///modules/ocf/common/puppet/ocf-puppetenv',
    require => Package['augeas-tools','puppet'],
  }

}
