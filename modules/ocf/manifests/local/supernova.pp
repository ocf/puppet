class ocf::local::supernova {

  package {
    # account approval dependencies
    ['python-cracklib', 'python-dnspython']:
    ;
    # account creation dependecies
    ['python-twisted', 'python-argparse', 'python-crypto']:
    ;
    # ldap management
    'ldapvi':
    ;
  }

  # ldapvi config
  file { '/etc/ldapvi.conf':
    content => "profile default\nldap-conf: yes\nsasl-mech: GSSAPI\n",
    require => Package['ldapvi'],
  }

}
