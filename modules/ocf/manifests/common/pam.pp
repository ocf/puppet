class ocf::common::pam( $login = '', $sudo = '' ) {

  # require kerberos and ldap configuration
  require ocf::common::kerberos
  require ocf::common::ldap

  # remove unnecessary pam profiles
  $pamconfig = '/usr/share/pam-configs'
  file { [ "$pamconfig/consolekit", "$pamconfig/gnome-keyring", "$pamconfig/ldap", "$pamconfig/libpam-mount" ]:
    ensure  => absent,
    backup  => false
  }
  exec { 'pam-auth-update':
    command     => 'pam-auth-update --package',
    refreshonly => true,
    subscribe   => File[ "$pamconfig/consolekit", "$pamconfig/gnome-keyring", "$pamconfig/ldap", "$pamconfig/libpam-mount" ]
  }

  # install kerberos pam module
  package { 'libpam-krb5': }

  # login access controls
  file {
    # create pam_access profile
    '/usr/share/pam-configs/access':
      source  => 'puppet:///modules/ocf/common/pam/access',
      require => File['/etc/security/access.conf'],
      notify  => Exec['pam-auth-update'];
    # provide access control table
    '/etc/security/access.conf':
      content => template('ocf/common/access.conf.erb');
  }

  # sudo access controls
  package { 'sudo': }
    file {
      '/etc/pam.d/sudo':
        source  => 'puppet:///modules/ocf/common/pam/sudo',
        require => Package['sudo'];
    }
  case $::hostname {
    spy:     {
      file {
        '/etc/sudoers':
          mode    => '0440',
          source  => 'puppet:///modules/ocf/local/spy/sudoers',
          require => Package['sudo'];
        }
      }
    default: {
      file {
        '/etc/sudoers':
          mode    => '0440',
          content => template('ocf/common/sudoers.erb'),
          require => Package['sudo'];
      }
    }
  }

}
