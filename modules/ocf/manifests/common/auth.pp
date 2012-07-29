class ocf::common::auth( $login = '', $sudo = '' ) {

  # require LDAP/Kerberos configuration
  require ocf::common::ldap
  require ocf::common::kerberos

  # NSS user/group identification
  ocf::repackage {
    # SSSD for users
    'sssd':
      recommends => false;
    'libnss-sss':
      recommends => false,
      require    => [ Ocf::Repackage['sssd'], File['/etc/sssd/sssd.conf'] ];
    # NSCD for groups
    'nscd':;
    'libnss-ldap':
      recommends => false
  }
  package { [ 'libnss-ldapd', 'libpam-ldap', 'libpam-sss', 'nslcd' ]:
    ensure => purged
  }
  file {
    # SSSD config
    '/etc/sssd/sssd.conf':
      mode    => '0600',
      source  => 'puppet:///modules/ocf/common/auth/sssd.conf',
      require => Ocf::Repackage['sssd'];
    # NSCD config
    '/etc/nscd.conf':
      source  => 'puppet:///modules/ocf/common/auth/nscd.conf',
      require => Ocf::Repackage['nscd'];
    # NSCD LDAP config
    '/etc/libnss-ldap.conf':
      source  => 'puppet:///modules/ocf/common/auth/libnss-ldap.conf',
      require => Ocf::Repackage['libnss-ldap'];
    # use SSSD for users and NSCD for groups
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/common/auth/nsswitch.conf',
      require => [ Ocf::Repackage['sssd','libnss-sss','libnss-ldap'], File['/etc/sssd/sssd.conf','/etc/libnss-ldap.conf'] ];
  }
  # restart SSSD
  service { 'sssd':
    subscribe => File['/etc/sssd/sssd.conf'],
    require   => Ocf::Repackage['sssd']
  }
  # restart NSCD
  service { 'nscd':
    subscribe => File['/etc/libnss-ldap.conf','/etc/nscd.conf'],
    require   => Ocf::Repackage['nscd']
  }

  # PAM user authentication
  # install Kerberos PAM module
  package { 'libpam-krb5': }
  # remove unnecessary pam profiles
  $pamconfig = '/usr/share/pam-configs'
  file { [ "$pamconfig/consolekit", "$pamconfig/gnome-keyring", "$pamconfig/ldap", "$pamconfig/libpam-mount" ]:
    ensure  => absent,
    backup  => false,
    notify  => Exec['pam-auth-update']
  }
  exec { 'pam-auth-update':
    command     => 'pam-auth-update --package',
    refreshonly => true
  }

  # PAM user/group access controls
  file {
    # create pam_access profile
    '/usr/share/pam-configs/access':
      source  => 'puppet:///modules/ocf/common/auth/pam/access',
      require => File['/etc/security/access.conf'],
      notify  => Exec['pam-auth-update'];
    # provide access control table
    '/etc/security/access.conf':
      content => template('ocf/common/access.conf.erb');
  }

  # SSH GSSAPI user authentication
  augeas { '/etc/ssh/sshd_config/GSSAPI':
    context => '/files/etc/ssh/sshd_config',
    changes => [
                 'set GSSAPIAuthentication yes',
                 'set GSSAPICleanupCredentials yes',
                 'set GSSAPIStrictAcceptorCheck no'
                ],
    require => Package['openssh-server'],
    notify  => Service['ssh']
  }

  # sudo user/group access controls
  package { 'sudo': }
  file {
    '/etc/pam.d/sudo':
      source  => 'puppet:///modules/ocf/common/auth/pam/sudo',
      require => Package['sudo'];
    '/etc/sudoers':
      mode    => '0440',
      content => template('ocf/common/sudoers.erb'),
      require => Package['sudo'];
  }

}
