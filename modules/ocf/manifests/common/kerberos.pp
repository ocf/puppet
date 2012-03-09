class ocf::common::kerberos {

  # install heimdal kerberos packages
  package { [ 'heimdal-clients', 'libsasl2-modules-gssapi-heimdal' ]: }

  # provide kerberos config and private keytab
  file {
    '/etc/krb5.conf':
      source  => 'puppet:///modules/ocf/common/krb5.conf',
      require => Package['heimdal-clients'];
    '/etc/krb5.keytab':
      mode    => '0600',
      backup  => false,
      source  => 'puppet:///private/krb5.keytab',
      require => Package['heimdal-clients'];
  }

}
