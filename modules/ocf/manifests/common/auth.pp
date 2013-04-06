class ocf::common::auth( $glogin = '', $ulogin = '', $gsudo = '', $usudo = '' ) {

  # require LDAP/Kerberos configuration
  require ocf::common::ldap
  require ocf::common::kerberos

  # NSS user/group identification
  ocf::repackage {
    # LDAP nameservice provider
    'libnss-ldap':
      recommends => false;
    # NSCD for LDAP caching
    'unscd':
      require    => Package['nscd'];
    # nss_updatedb for offline LDAP caching
    'nss-updatedb':
  }
  package { [ 'libnss-ldapd', 'libnss-sss', 'libpam-ldap', 'libpam-sss', 'nslcd', 'nscd', 'sssd' ]:
    ensure => purged
  }
  file {
    # store local copy of LDAP daily with nss_updatedb
    '/etc/cron.daily/nss-updatedb':
      mode    => '0755',
      content => "#!/bin/sh\nnss_updatedb ldap > /dev/null",
      require => Ocf::Repackage['nss-updatedb'];
    # NSCD caching configuration
    '/etc/nscd.conf':
      source  => 'puppet:///modules/ocf/common/auth/nss/nscd.conf',
      require => Ocf::Repackage['unscd'];
    # LDAP nameservice configuration
    '/etc/libnss-ldap.conf':
      ensure  => symlink,
      links   => manage,
      target  => '/etc/ldap.conf',
      require => Ocf::Repackage['libnss-ldap'];
    # nameservice configuration: use LDAP but failover to local copy
    '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/common/auth/nss/nsswitch.conf',
      require => [ Ocf::Repackage['libnss-ldap'], File['/etc/libnss-ldap.conf'] ];
  }
  # restart NSCD
  service { 'unscd':
    subscribe => File['/etc/nscd.conf', '/etc/nsswitch.conf'],
    require   => Ocf::Repackage['unscd']
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
