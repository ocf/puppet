class ocf::packages::ssh {

  # install ssh client and server
  package { [ 'openssh-client', 'openssh-server' ]: }

  file {
    # enable GSSAPI host key verification
    '/etc/ssh/ssh_config':
      source  => 'puppet:///modules/ocf/ssh_config',
      require => Package['openssh-client'],
    ;
  }

  service { 'ssh':
    require => Package['openssh-server'],
  }

}
