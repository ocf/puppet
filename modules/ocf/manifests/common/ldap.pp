class ocf::common::ldap {

  # install LDAP packages
  package { [ 'ldap-utils', 'unscd', 'openssl' ]: }
  ocf::repackage { 'libnss-ldap':
    recommends => false,
  }

  file {
    # provide LDAP config
    '/etc/ldap/ldap.conf':
      source  => 'puppet:///modules/ocf/common/ldap/ldap.conf',
      require => Package['ldap-utils'];
    # provide LDAP user/group lookup config
    '/etc/libnss-ldap.conf':
      source  => 'puppet:///modules/ocf/common/ldap/libnss-ldap.conf',
      require => Ocf::Repackage['libnss-ldap'];
    # provide nsswitch config
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/common/ldap/nsswitch.conf',
      require => [ File['/etc/libnss-ldap.conf'], Exec['c_rehash'] ];
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

  # restart getent caching daemon
  service { 'unscd':
    subscribe => File[ '/etc/libnss-ldap.conf','/etc/nsswitch.conf' ],
    require   => Package['unscd']
  }

}
