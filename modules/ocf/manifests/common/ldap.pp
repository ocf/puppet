class ocf::common::ldap {

  # LDAP packages
  package { [ 'ldap-utils', 'nscd', 'openssl' ]: }
  ocf::repackage { 'libnss-ldap':
    recommends  => false,
    require     => Package['nscd'];
  }

  file {
    # provide LDAP connection config
    '/etc/ldap/ldap.conf':
      source  => 'puppet:///modules/ocf/common/ldap/ldap.conf',
      require => Package['ldap-utils'];
    # provide LDAP name service config
    '/etc/libnss-ldap.conf':
      source  => 'puppet:///modules/ocf/common/ldap/libnss-ldap.conf',
      require => Ocf::Repackage['libnss-ldap'];
    # provide name service config
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/common/ldap/nsswitch.conf',
      require => [ Package['nscd'], File['/etc/libnss-ldap.conf'], Exec['c_rehash'] ];
    # provide certificate authority
    '/etc/ssl/certs/ocf_ca.pem':
      source  => 'puppet:///modules/ocf/common/ldap/ocf_ca.pem',
      require => Package['openssl']
  }

  # create necessary symlinks for certificate authority
  exec { 'c_rehash':
    refreshonly => true,
    subscribe   => File['/etc/ssl/certs/ocf_ca.pem'],
    require     => Package['openssl']
  }

  # restart name service caching daemon
  service { 'nscd':
    subscribe => File[ '/etc/libnss-ldap.conf','/etc/nsswitch.conf' ],
    require   => Package['nscd']
  }

}
