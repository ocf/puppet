class ocf_ldap {
  include ocf::ssl::default

  # Install libarchive-zip-perl for crc32 command for calculating hashes of
  # ldif files in /etc/ldap/slapd.d, slapd is the ldap server
  package { ['slapd', 'ocf-ldap-overlay', 'libarchive-zip-perl']:; }
  service { 'slapd':
    subscribe => [
      File['/etc/ldap/schema/ocf.schema',
        '/etc/ldap/schema/puppet.schema',
        '/etc/ldap/sasl2/slapd.conf',
        '/etc/ldap/slapd.conf'],
      Augeas['/etc/default/slapd'],
      Class['ocf::ssl::default'],
    ],
  }

  user { 'openldap':
    groups  => 'ssl-cert',
    require => Package['slapd'],
  }

  file {
    '/etc/ldap/slapd.conf':
      content => template('ocf_ldap/slapd.conf.erb'),
      require => Package['slapd', 'ocf-ldap-overlay'];

    '/etc/ldap/schema/ocf.schema':
      source  => 'puppet:///modules/ocf_ldap/ocf.schema',
      require => Package['slapd'];

    '/etc/ldap/schema/puppet.schema':
      source  => 'puppet:///modules/ocf_ldap/puppet.schema',
      require => Package['slapd'];

    '/etc/ldap/sasl2/slapd.conf':
      source  => 'puppet:///modules/ocf_ldap/sasl2-slapd',
      require => Package['slapd', 'libsasl2-modules-gssapi-mit'];
  }

  ocf::privatefile { '/etc/ldap/krb5.keytab':
    source  => 'puppet:///private/krb5-ldap.keytab',
    owner   => openldap,
    group   => openldap,
    mode    => '0600',
    require => Package['slapd', 'heimdal-clients'],
    notify  => Service['slapd'],
  }

  augeas { '/etc/default/slapd':
    context => '/files/etc/default/slapd',
    changes => [
      'set SLAPD_CONF /etc/ldap/slapd.conf',
      'set SLAPD_SERVICES \'"ldaps:///"\'',
      'touch KRB5_KTNAME/export',
      'set KRB5_KTNAME /etc/ldap/krb5.keytab',
    ],
    require => Package['slapd'],
  }

  # Daily local git backup
  package { 'ldap-git-backup':; }

  cron { 'ldap-git-backup':
    # Back up all of LDAP, including configuration options
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=721155
    #
    # Make sure this occurs before the rsync backup for rsnapshot, since this
    # ensures we have a more recent daily backup stored on our backup server
    command => '/usr/sbin/ldap-git-backup',
    minute  => 0,
    hour    => 1,
    require => Package['ldap-git-backup'];
  }

  file {
    # Use the puppet cron task instead of the packaged cron script for more
    # configurability and similarity with the kerberos-git-backup cron setup
    '/etc/cron.d/ldap-git-backup':
      ensure => absent;

    # ldap-git-backup complains if the directory it backs up to is
    # world-readable, so set it and the kerberos backups for consistency to be
    # usable only by root.
    ['/var/backups/ldap', '/var/backups/kerberos']:
      ensure => directory,
      mode   => '0700';
  }

  # Pushing to GitHub is disabled for dev-* hosts to prevent duplicate backups
  if $::host_env == 'prod' {
    # GitHub deploy hook and key
    file {
      '/var/backups/ldap/.git/hooks/post-commit':
        content => "git push -q git@github.com:ocf/ldap master\n",
        mode    => '0755',
        require => Package['ldap-git-backup'];

      '/root/.ssh':
        ensure => directory,
        mode   => '0700';

      # This is to stop backups from sending emails every time a new IP is used
      # See rt#4724 for more information
      '/root/.ssh/known_hosts':
        source => 'puppet:///modules/ocf_ldap/github_known_hosts';
    }

    ocf::privatefile { '/root/.ssh/id_rsa':
      source => 'puppet:///private/id_rsa',
      mode   => '0600',
      before => File['/var/backups/ldap/.git/hooks/post-commit'];
    }
  }

  cron { 'ldap-lint':
    command => '/opt/share/utils/sbin/ldap-lint',
    user    => root,
    special => 'daily',
    require => Vcsrepo['/opt/share/utils'];
  }

  ocf::munin::plugin { 'slapd-open-files':
    source => 'puppet:///modules/ocf_ldap/munin/slapd-open-files',
    user   => root,
  }

  # firewall input rule, allow ldaps, port number 636
  ocf::firewall::firewall46 {
    '101 allow ldaps':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => ['tcp', 'udp'],
        dport  => 636,
        action => 'accept',
      };
  }

  package { ['sasl2-bin']:; }
  augeas { '/etc/default/saslauthd':
    context => '/files/etc/default/saslauthd',
    changes => [
      'set MECHANISMS \'"kerberos5"\'',
      'set START \'"yes"\'',
    ],
    require => Package['sasl2-bin'],
  }
}
