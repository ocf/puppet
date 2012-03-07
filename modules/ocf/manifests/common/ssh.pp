class ocf::common::ssh {

  require ocf::common::kerberos

  # install ssh client and server
  package { [ 'openssh-client', 'openssh-server' ]: }

  # provide ssh client/server config and list of hosts
  file {
    '/etc/ssh/ssh_config':
      source  => 'puppet:///modules/ocf/common/ssh/ssh_config',
      require => Package['openssh-client'];
    '/etc/ssh/sshd_config':
      source  => 'puppet:///modules/ocf/common/ssh/sshd_config',
      require => Package['openssh-server'];
    '/etc/ssh/ssh_known_hosts':
      source  => 'puppet:///modules/ocf/common/ssh/ssh_known_hosts',
      require => Package['openssh-server'];
  }

  # start ssh server
  service { 'ssh':
    subscribe => File['/etc/ssh/sshd_config'],
    require   => Package['openssh-server']
  }

}
