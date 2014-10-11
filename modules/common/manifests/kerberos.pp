class common::kerberos {

  # install Heimdal Kerberos packages
  package { [ 'heimdal-clients', 'libsasl2-modules-gssapi-mit' ]: }

  # provide Kerberos config
  file { '/etc/krb5.conf':
    source  => 'puppet:///modules/common/auth/krb5.conf',
    require => Package['heimdal-clients']
  }

  # provide Kerberos private keytab
  file { '/etc/krb5.keytab':
    mode   => '0600',
    backup => false,
    source => 'puppet:///private/krb5.keytab'
  }

  # enable SSH host key verification
  augeas { '/etc/ssh/sshd_config/GSSAPIKeyExchange':
    context => '/files/etc/ssh/sshd_config',
    changes => 'set GSSAPIKeyExchange yes',
    require => [ Package['openssh-server'], File['/etc/krb5.conf'], File['/etc/krb5.keytab'] ],
    notify  => Service['ssh']
  }

}
