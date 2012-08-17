class ocf::local::firestorm {
  ##Heimdal server configuration##
  # if local realm has not been defined installation will fail
  package {
    'heimdal-kdc':
      require => File['/etc/krb5.conf'];
  }

  #define logrotate so we can modify the conf
  package { ['logrotate']: }

  file {
    '/etc/logrotate.d/heimdal-kdc':
    source  => 'puppet:///modules/ocf/local/firestorm/heimdal-kdc-logrotate',
    require => [ Package['heimdal-kdc'], Package['logrotate'] ]
  }

  #define the heimdal service
  service {
    'heimdal-kdc':
      subscribe => File[ '/etc/heimdal-kdc/kdc.conf', '/etc/heimdal-kdc/kadmind.acl' ]
  }

  file {
    '/etc/heimdal-kdc/kdc.conf':
      source  => 'puppet:///modules/ocf/local/firestorm/kdc.conf',
      require => [ Package['heimdal-kdc'] ],
  }

  file {
    '/etc/heimdal-kdc/kadmind.acl':
      source  => 'puppet:///modules/ocf/local/firestorm/kadmind.acl',
      require => [ Package['heimdal-kdc'] ],
  }

  ##Ldap server install##
  #Packages
  package { ['slapd', 'libsasl2-modules-gssapi-heimdal']: }

  #define service
  service {
    'slapd':
      subscribe => File[ '/etc/ldap/slapd.conf', '/etc/ldap/schema/ocf.schema', '/etc/ldap/ocf_ldap.key', '/etc/default/slapd','/etc/ldap/sasl2/slapd.conf']
  }

  #needed config files
  file {
    '/etc/ldap/slapd.conf':
      source  => 'puppet:///modules/ocf/local/firestorm/slapd.conf',
      require => [ Package['slapd'] ],
  }

  file {
    '/etc/ldap/schema/ocf.schema':
      source  => 'puppet:///modules/ocf/local/firestorm/ocf.schema',
      require => [ Package['slapd'] ],
  }

  file {
    '/etc/ldap/ocf_ldap.key':
      source  => 'puppet:///private/ocf_ldap.key',
      require => [ Package['slapd'], Package['openssl'] ],
      mode    => '0600',
      owner   => 'openldap',
      group   => 'openldap',
  }

  file {
    '/etc/default/slapd':
      source  => 'puppet:///modules/ocf/local/firestorm/slapd-defaults',
      require =>  [ Package['slapd'], Package['openssl'] ],
  }

  file {
    '/etc/ldap/sasl2/slapd.conf':
      source  => 'puppet:///modules/ocf/local/firestorm/sasl2-slapd',
      require =>  [ Package['slapd'], Package['libsasl2-modules-gssapi-heimdal'] ],
  }

  file {
    '/etc/ldap/krb5.keytab':
      source  => 'puppet:///private/krb5-ldap.keytab',
      require => [ Package['slapd'], Package['heimdal-clients'] ],
      mode    => '0600',
      owner   => 'openldap',
      group   => 'openldap',
  }

}
