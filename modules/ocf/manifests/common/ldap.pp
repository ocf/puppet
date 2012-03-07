class ocf::common::ldap {

  # install ldap packages
  package { [ 'libpam-ldapd', 'libnss-ldapd', 'ldap-utils', 'openssl' ]: }

  file {
    # provide ldap config
    '/etc/ldap/ldap.conf':
      source  => 'puppet:///modules/ocf/common/ldap/ldap.conf',
      require => Package[ 'ldap-utils' ];
    # provide nslcd config
    '/etc/nslcd.conf':
      source  => 'puppet:///modules/ocf/common/ldap/nslcd.conf',
      require => Package[ 'libpam-ldapd', 'libnss-ldapd' ];
    # provide nsswitch config
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/common/ldap/nsswitch.conf',
      require => Service['nslcd'];
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

  # restart LDAP caching daemon
  service { 'nslcd':
    subscribe => [ File[ '/etc/ldap/ldap.conf', '/etc/nslcd.conf' ], Exec['c_rehash'] ],
    require   => Package[ 'libpam-ldapd', 'libnss-ldapd' ]
  }

  # restart getent caching daemon
  service { 'nscd':
    subscribe => [ Service['nslcd'], File['/etc/nsswitch.conf'] ]
  }

}
