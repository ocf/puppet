class common::ldap {

  # LDAP packages
  package { [ 'ldap-utils', 'openssl' ]: }

  file {
    # provide LDAP connection config
    '/etc/ldap.conf':
      source  => 'puppet:///modules/common/auth/ldap/ldap.conf',
      require => [ Package['ldap-utils'], File['/etc/ldap/cacert.pem'] ]
    ;
    '/etc/ldap/ldap.conf':
      ensure  => symlink,
      links   => manage,
      target  => '/etc/ldap.conf',
    ;
    # provide LDAP CA certificate
    '/etc/ldap/cacert.pem':
      source  => 'puppet:///modules/common/auth/ldap/cacert.pem',
      require => Package['openssl'],
    ;
  }

}
