class common::ldap {
  package { ['ldap-utils', 'openssl']:; }

  file {
    '/etc/ldap.conf':
      source  => 'puppet:///modules/common/auth/ldap/ldap.conf',
      require => Package['ldap-utils'];

    '/etc/ldap/ldap.conf':
      ensure  => symlink,
      target  => '/etc/ldap.conf';
  }
}
