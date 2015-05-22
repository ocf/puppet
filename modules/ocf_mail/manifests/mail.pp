class ocf_mail::mail {
  # backport postfix because debian postfix-ldap packages prior to 2.11.1-1 are
  # compiled without -DUSE_LDAP_SASL, and wheezy has only 2.9.6
  #
  # we need LDAP SASL support in order to auth with a GSSAPI LDAP bind to
  # access users' mail LDAP attributes for mail forwarding
  ocf::repackage {
    'postfix':
      backport_on => 'wheezy';
    'postfix-ldap':
      backport_on => 'wheezy';
  }

  package {
    ['clamav-milter', 'spamassassin', 'spamass-milter', 'postgrey',
    'policyd-weight', 'rt4-clients']:;
  }

  service {
    'postfix':
      require => [Ocf::Repackage['postfix'], Package['rt4-clients']];
    'spamassassin':
      require => [Package['spamassassin'], User['spamd']];
    'spamass-milter':
      require => Package['spamass-milter'];
    'clamav-milter':
      require => Package['clamav-milter'];
    'postgrey':
      require => Package['postgrey'];
    'policyd-weight':
      require => Package['policyd-weight'];
  }

  user {
    'spamd':
      ensure  => present,
      name    => 'spamd',
      gid     => 'spamd',
      groups  => ['sys'],
      home    => '/var/lib/spamd',
      shell   => '/bin/false',
      system  => true,
      require => Group['spamd'];
    'ocfmail':
      ensure  => present,
      name    => 'ocfmail',
      gid     => 'ocfmail',
      groups  => ['sys'],
      home    => '/var/mail',
      shell   => '/bin/false',
      system  => true,
      require => Group['ocfmail'];
  }

  group {
    'spamd':
      ensure  => present,
      name    => 'spamd',
      system  => true;
    'ocfmail':
      ensure  => present,
      name    => 'ocfmail',
      system  => true;
  }

  exec {
    'newaliases':
      refreshonly => true,
      command     => '/usr/bin/newaliases',
      require     => Service['postfix'];
  }

  cron {
    'update-aliases':
      command => '/usr/local/sbin/update-aliases',
      user    => root,
      hour    => '*',
      minute  => '*/15',
      require => [
        File['/usr/local/sbin/update-aliases'],
        Service['postfix']
      ];

    'update-nomail-hashes':
      command => '/usr/local/sbin/update-nomail-hashes',
      user    => root,
      hour    => '*',
      minute  => '*/15',
      require => [
        File['/usr/local/sbin/update-nomail-hashes'],
        Service['postfix']
      ];

    'update-cred-cache':
      command => '/usr/local/sbin/update-cred-cache',
      user    => root,
      special => 'hourly',
      require => [
        File['/usr/local/sbin/update-cred-cache'],
        File['/etc/postfix/ocf/smtp-krb5.keytab'],
        Service['postfix']
      ];

    'update-cred-cache-reboot':
      command => '/usr/local/sbin/update-cred-cache',
      user    => root,
      special => 'reboot',
      require => [
        File['/usr/local/sbin/update-cred-cache'],
        File['/etc/postfix/ocf/smtp-krb5.keytab'],
        Service['postfix']
      ];
  }

  file {
    # ssl
    '/etc/ssl/private/anthrax.ocf.berkeley.edu.key':
      mode    => '0600',
      owner   => root,
      group   => root,
      source  => 'puppet:///private/ssl/anthrax.ocf.berkeley.edu.key',
      require => Ocf::Repackage['postfix'];
    '/etc/ssl/private/anthrax.ocf.berkeley.edu.crt':
      mode    => '0644',
      source  => 'puppet:///private/ssl/anthrax.ocf.berkeley.edu.crt',
      require => Ocf::Repackage['postfix'];
    '/etc/postfix/ocf/smtp-krb5.keytab':
      mode    => '0600',
      owner   => root,
      group   => root,
      source  => 'puppet:///private/smtp-krb5.keytab',
      require => Ocf::Repackage['postfix'];

    # postfix config
    '/etc/postfix/main.cf':
      mode    => '0644',
      source  => 'puppet:///modules/anthrax/postfix/main.cf',
      notify  => Service['postfix'],
      require => Ocf::Repackage['postfix'];
    '/etc/postfix/ldap-aliases.cf':
      mode    => '0644',
      source  => 'puppet:///modules/anthrax/postfix/ldap-aliases.cf',
      notify  => Service['postfix'],
      require => Ocf::Repackage['postfix'];
    '/etc/postfix/ocf':
      ensure  => directory,
      require => Service['postfix'];
    '/etc/postfix/ocf/nomail':
      ensure  => file,
      require => Service['postfix'];
    '/etc/postfix/ocf/helo_access':
      source  => 'puppet:///modules/anthrax/postfix/helo_access',
      require => Service['postfix'];

    # aliases and hashes
    '/etc/aliases':
      mode    => '0644',
      source  => 'puppet:///modules/anthrax/aliases',
      notify  => Exec['newaliases'];
    '/usr/local/sbin/update-aliases':
      mode    => '0755',
      source  => 'puppet:///modules/anthrax/update-aliases';
    '/usr/local/sbin/update-nomail-hashes':
      mode    => '0755',
      source  => 'puppet:///modules/anthrax/update-nomail-hashes';
    '/usr/local/sbin/update-cred-cache':
      mode    => '0755',
      source  => 'puppet:///modules/anthrax/update-cred-cache';

    # badness filtering
    '/etc/default/spamassassin':
      source  => 'puppet:///modules/anthrax/spamass/spamassassin',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/etc/spamassassin/local.cf':
      source  => 'puppet:///modules/anthrax/spamass/local.cf',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/etc/spamassassin/v310.pre':
      source  => 'puppet:///modules/anthrax/spamass/v310.pre',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/var/lib/spamd':
      ensure  => directory,
      owner   => spamd,
      mode    => '0755',
      require => User['spamd'];
    '/etc/default/spamass-milter':
      source  => 'puppet:///modules/anthrax/spamass/spamass-milter',
      notify  => Service['spamass-milter'],
      require => Package['spamass-milter'];
    '/var/spool/postfix/clamav':
      ensure  => directory,
      owner   => clamav,
      group   => root;
    '/etc/default/clamav-milter':
      source  => 'puppet:///modules/anthrax/clamav/clamav-milter',
      notify  => Service['clamav-milter'],
      require => [Package['clamav-milter'], File['/var/spool/postfix/clamav']];
    '/etc/clamav/clamav-milter.conf':
      source  => 'puppet:///modules/anthrax/clamav/clamav-milter.conf',
      notify  => Service['clamav-milter'],
      require => Package['clamav-milter'];
    '/etc/default/postgrey':
      source  => 'puppet:///modules/anthrax/postgrey/postgrey',
      notify  => Service['postgrey'],
      require => Package['postgrey'];
    '/etc/policyd-weight.conf':
      source  => 'puppet:///modules/anthrax/policyd-weight/policyd-weight.conf',
      notify  => Service['policyd-weight'],
      require => Package['policyd-weight'];

    # outgoing nomail logging
    '/var/mail/nomail':
      ensure  => directory,
      mode    => '0755',
      owner   => ocfmail,
      group   => ocfmail;
    '/etc/logrotate.d/nomail':
      ensure  => file,
      source  => 'puppet:///modules/anthrax/logrotate/nomail';
  }
}
