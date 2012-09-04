class ocf::common::kerberos {

  # install Heimdal Kerberos packages
  package { [ 'heimdal-clients', 'libsasl2-modules-gssapi-mit' ]: }

  # provide Kerberos config
  # Augeas does not work consistently, so reverting back to serving file  
  #augeas { '/etc/krb5.conf':
  #  context => '/files/etc/krb5.conf',
  #  changes => [
  #               'set libdefaults/default_realm OCF.BERKELEY.EDU',
  #               'set realms/realm/kdc kerberos.ocf.berkeley.edu',
  #               'set realms/realm/admin_server kerberos.ocf.berkeley.edu',
  #               'set domain_realm/.ocf.berkeley.edu OCF.BERKELEY.EDU',
  #               'set domain_realm/ocf.berkeley.edu OCF.BERKELEY.EDU',
  #               'set domain_realm/.lab.ocf.berkeley.edu OCF.BERKELEY.EDU',
  #               'set domain_realm/lab.ocf.berkeley.edu OCF.BERKELEY.EDU',
  #              ],
  file { '/etc/krb5.conf':
    source  => 'puppet:///modules/ocf/common/auth/krb5.conf',
    require => Package['heimdal-clients']
  }

  # provide Kerberos private keytab
  file { '/etc/krb5.keytab':
    mode    => '0600',
    backup  => false,
    source  => 'puppet:///private/krb5.keytab'
  }

  # enable SSH host key verification
  augeas { '/etc/ssh/sshd_config/GSSAPIKeyExchange':
    context => '/files/etc/ssh/sshd_config',
    changes => 'set GSSAPIKeyExchange yes',
    require => [ Package['openssh-server'], File['/etc/krb5.conf'], File['/etc/krb5.keytab'] ],
    notify  => Service['ssh']
  }

}
