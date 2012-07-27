class ocf::common::ssh {

  # install ssh client and server
  package { [ 'openssh-client', 'openssh-server' ]: }

  # for readability, do not hash known_hosts file by default
  # enable GSSAPI host key verification
  augeas { '/etc/ssh/ssh_config':
    context => '/files/etc/ssh/ssh_config',
    changes => [ 
                 'set HashKnownHosts no',
                 'set GSSAPIAuthentication yes',
                 'set GSSAPIKeyExchange yes',
                 'set GSSAPIDelegateCredentials no'
                ],
    require => Package['openssh-client']
  }

  # provide list of ssh hosts
  file { '/etc/ssh/ssh_known_hosts':
      source  => 'puppet:///contrib/common/ssh_known_hosts',
      require => Package['openssh-client'];
  }

  service { 'ssh':
    require => Package['openssh-server']
  }

}
