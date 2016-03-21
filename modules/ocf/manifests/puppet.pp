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
      # These changes can change the puppetmaster config, which is
      # defined separately in the ocf_puppet module, causing the
      # puppet agent on the puppetmaster to restart twice. Make sure
      # the changes made here are also made in that module.
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

  mount { '/var/lib/puppet/concat':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'noatime,nodev,nosuid';
  }

  # install augeas
  package { [ 'augeas-tools', 'libaugeas-ruby', ]: }

  # install custom scripts
  file {
    # trigger a puppet run by the agent
    '/usr/local/sbin/puppet-trigger':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/puppet-trigger',
      require => Package['puppet'],
    ;
  }
}
