class ocf::puppet {
  package { ['facter', 'puppet']: }

  # enable puppet agent
  # TODO: can we remove this after wheezy is kill?
  file { '/etc/default/puppet':
    content => "START=yes\n",
    notify  => Service['puppet'],
  }

  # configure puppet agent
  # set environment to match server and disable cached catalog on failure
  augeas { '/etc/puppet/puppet.conf':
    context => '/files/etc/puppet/puppet.conf',
    changes => [
      "set agent/environment ${::environment}",
      'set agent/usecacheonfailure false',
      'set main/pluginsync true',
      'set main/stringify_facts false',

      # future parser breaks too many 3rd-party modules
      'rm main/parser',
    ],
    require => Package['augeas-tools', 'libaugeas-ruby', 'puppet'],
    notify  => Service['puppet'],
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

  # install augeas
  package { [ 'augeas-tools', 'libaugeas-ruby', ]: }

  # install custom scripts
  file {
    # list files in a directory managed by puppet
    '/usr/local/sbin/puppet-ls':
      mode    => '0755',
      source  => 'puppet:///contrib/common/puppet-ls',
      require => Package['puppet'],
    ;
    # trigger a puppet run by the agent
    '/usr/local/sbin/puppet-trigger':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/puppet-trigger',
      require => Package['puppet'],
    ;
  }
}
