class ocf::packages::ldapvi {
  package { 'ldapvi': }
  file { '/etc/ldapvi.conf':
    content => "profile default\nldap-conf: yes\nsasl-mech: GSSAPI\n",
    require => Package['ldapvi'],
  }
}
