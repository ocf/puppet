class ocf::groups {
  # fix creation of conflicting system groups
  file { 'groups.sh':
    path    => '/opt/share/puppet/groups.sh',
    mode    => '0755',
    source  => 'puppet:///modules/ocf/groups.sh',
    require => Class['ocf::puppet']
  }

  exec { 'groups.sh':
    command     => '/opt/share/puppet/groups.sh',
    refreshonly => true,
    subscribe   => File['groups.sh']
  }
}
