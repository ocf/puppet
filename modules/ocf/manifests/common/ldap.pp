class ocf::common::ldap {

  # LDAP packages
  package { [ 'ldap-utils', 'openssl' ]: }

  file {
    # provide LDAP connection config
    '/etc/ldap/ldap.conf':
      source  => 'puppet:///modules/ocf/common/auth/ldap.conf',
      require => Package['ldap-utils'];
    # provide certificate authority
    '/etc/ssl/certs/ocf_ca.pem':
      source  => 'puppet:///modules/ocf/common/auth/ocf_ca.pem',
      require => Package['openssl']
  }

  # create necessary symlinks for certificate authority
  exec { 'c_rehash':
    refreshonly => true,
    subscribe   => File['/etc/ssl/certs/ocf_ca.pem'],
    require     => Package['openssl']
  }

}
