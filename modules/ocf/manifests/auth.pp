class ocf::auth($glogin = [], $ulogin = [[]], $gsudo = [], $usudo = [], $nopasswd = false) {
  # require LDAP/Kerberos configuration
  require ocf::ldap
  require ocf::kerberos

  # NSS user/group identification
  ocf::repackage {
    # LDAP nameservice provider
    'libnss-ldap':
      recommends => false;
  }

  package {
    # UNSCD for LDAP caching
    'unscd':
      require => Package['nscd'];

    # nss_updatedb for offline LDAP caching
    'nss-updatedb':;
  }

  package { [ 'libnss-ldapd', 'libnss-sss', 'libpam-ldap', 'libpam-sss', 'nslcd', 'nscd', 'sssd' ]:
    ensure => purged
  }

  file {
    # TODO: Remove this once all hosts have switched over to using cron instead
    '/etc/cron.daily/nss-updatedb':
      ensure => absent;

    # NSCD caching configuration
    '/etc/nscd.conf':
      source  => 'puppet:///modules/ocf/auth/nss/nscd.conf',
      require => Package['unscd'];

    # LDAP nameservice configuration
    '/etc/libnss-ldap.conf':
      ensure  => symlink,
      links   => manage,
      target  => '/etc/ldap.conf',
      require => Ocf::Repackage['libnss-ldap'];
  }

  # Store local copy of LDAP daily with nss_updatedb
  # This used to be done in /etc/cron.daily, but all the servers storing a
  # local copy at the same time was causing the LDAP server to get rekt
  cron {
    'nss-updatedb':
      command => 'nss_updatedb ldap > /dev/null',
      hour    => '6',
      minute  => fqdn_rand(60),
      require => Package['nss-updatedb'],
  }

  # nameservice configuration
  if $::skip_ldap {
    # use local copy only (never consult LDAP during lookups);
    # this is useful for servers which expect to not have connectivity to ldap
    #
    # (they will still use passwd/group from the nss db, which is updated
    # from ldap, but ldap isn't needed constantly)
    file { '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/auth/nss/nsswitch-noldap.conf',
      require => [Ocf::Repackage['libnss-ldap'], File['/etc/libnss-ldap.conf']];
    }
  } else {
    # use LDAP but failover to local copy
    file { '/etc/nsswitch.conf':
      source  => 'puppet:///modules/ocf/auth/nss/nsswitch.conf',
      require => [Ocf::Repackage['libnss-ldap'], File['/etc/libnss-ldap.conf']];
    }
  }

  # restart NSCD
  service { 'unscd':
    subscribe => File['/etc/nscd.conf', '/etc/nsswitch.conf'],
    require   => Package['unscd']
  }

  # PAM user authentication
  unless $::skip_kerberos {
    # install Kerberos PAM module
    package { 'libpam-krb5': }
  }

  # remove unnecessary pam profiles
  $pamconfig = '/usr/share/pam-configs'
  file { [ "${pamconfig}/consolekit", "${pamconfig}/gnome-keyring", "${pamconfig}/ldap", "${pamconfig}/libpam-mount" ]:
    ensure => absent,
    backup => false,
    notify => Exec['pam-auth-update']
  }

  exec { 'pam-auth-update':
    command     => 'pam-auth-update --package',
    refreshonly => true
  }

  # PAM user/group access controls
  file {
    # create pam_access profile
    '/usr/share/pam-configs/access':
      source  => 'puppet:///modules/ocf/auth/pam/access',
      require => File['/etc/security/access.conf'],
      notify  => Exec['pam-auth-update'];

    # provide access control table
    '/etc/security/access.conf':
      content => template('ocf/access.conf.erb');

    # Create pam_mkhomedir profile
    '/usr/share/pam-configs/mkhomedir':
      source => 'puppet:///modules/ocf/auth/pam/mkhomedir',
      notify => Exec['pam-auth-update'];
  }

  # Enable GSSAPI and root login, disable sorried forwarding
  augeas { 'sshd_config':
    context => '/files/etc/ssh/sshd_config',
    changes => [
      'set GSSAPIAuthentication yes',
      'set GSSAPICleanupCredentials yes',
      'set GSSAPIStrictAcceptorCheck no',

      'set PermitRootLogin yes',

      'set Match/Condition/Group sorry',
      'set Match/Settings/AllowTcpForwarding no',
      'set Match/Settings/X11Forwarding no',
      'set Match/Settings/AllowAgentForwarding no',
    ],
    require => Package['openssh-server'],
    notify  => Service['ssh']
  }

  augeas { 'sshd_config UseDNS':
    context => '/files/etc/ssh/sshd_config',
    changes => [
      # Lookup connected IPs and resolve to hostnames
      # Mostly just for convenience, but also matters for access.conf rules
      # Match blocks are annoying in sshd_config and need extra work to use
      # http://augeas.net/docs/references/lenses/files/sshd-aug.html#Sshd.CAVEATS
      'ins UseDNS before Match',
      'set UseDNS yes',
    ],
    onlyif  => 'match UseDNS size == 0',
    require => Augeas['sshd_config'],
    notify  => Service['ssh']
  }

  # remove SSH key used by makevm for bootstrapping after root login enabled
  file { '/root/.ssh/authorized_keys':
    ensure  => absent,
    require => Augeas['sshd_config'],
  }

  # Get all DNS names, FQDNs, and IPs for a host to include in SSH keys
  $ssh_aliases = delete(concat(
    suffix(delete(any2array($::dnsA), ''), ".${::domain}"),
    $::dnsA,
    suffix(delete(any2array($::dnsCname), ''), ".${::domain}"),
    $::dnsCname,
    $::fqdn,
    $::ipHostNumber,
    $::ipaddress6,
  ), '')

  # Export SSH keys from every host if PuppetDB is running, and use them
  # to populate the global list in /etc/ssh/ssh_known_hosts.
  if str2bool($::puppetdb_running) {
    @@sshkey { $::hostname:
      host_aliases => $ssh_aliases,
      key          => $::sshecdsakey,
      type         => ecdsa-sha2-nistp256,
    }
    Sshkey <<| |>>

    file { '/etc/ssh/ssh_known_hosts':
      mode => '0644',
    }
  }

  # sudo user/group access controls
  package { 'sudo': }
  file {
    '/etc/pam.d/sudo':
      source  => 'puppet:///modules/ocf/auth/pam/sudo',
      require => Package['sudo'];
    '/etc/sudoers':
      mode    => '0440',
      content => template('ocf/sudoers.erb'),
      require => Package['sudo'];
  }
}
