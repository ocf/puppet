class common::groups {
  # fix creation of conflicting system groups
  file { 'groups.sh':
    path    => '/opt/share/puppet/groups.sh',
    mode    => '0755',
    source  => 'puppet:///modules/common/groups.sh',
    require => Class['common::puppet']
  }

  exec { 'groups.sh':
    command     => '/opt/share/puppet/groups.sh',
    refreshonly => true,
    subscribe   => File['groups.sh']
  }
}
