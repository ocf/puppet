class ocf_ldap {
  include ocf_ssl::default_bundle

  package { 'slapd':; }
  service { 'slapd':
    subscribe => File[
      '/etc/ldap/slapd.conf',
      '/etc/ldap/schema/ocf.schema',
      '/etc/ldap/schema/puppet.schema',
      '/etc/default/slapd',
      '/etc/ldap/sasl2/slapd.conf'];
  }

  file {
    '/etc/ldap/slapd.conf':
      source  => 'puppet:///modules/ocf_ldap/slapd.conf',
      require => Package['slapd'];

    '/etc/ldap/schema/ocf.schema':
      source  => 'puppet:///modules/ocf_ldap/ocf.schema',
      require => Package['slapd'];

    '/etc/ldap/schema/puppet.schema':
      source  => 'puppet:///modules/ocf_ldap/puppet.schema',
      require => Package['slapd'];

    '/etc/default/slapd':
      source  => 'puppet:///modules/ocf_ldap/slapd-defaults',
      require => Package['slapd', 'openssl'];

    '/etc/ldap/sasl2/slapd.conf':
      source  => 'puppet:///modules/ocf_ldap/sasl2-slapd',
      require => Package['slapd', 'libsasl2-modules-gssapi-mit'];

    '/etc/ldap/krb5.keytab':
      source  => 'puppet:///private/krb5-ldap.keytab',
      owner   => openldap,
      group   => openldap,
      mode    => '0600',
      require => Package['slapd', 'heimdal-clients'];
  }

  # Daily local git backup
  package { 'ldap-git-backup':; }

  cron { 'ldap-git-backup':
    command => '/usr/sbin/ldap-git-backup',
    minute  => 0,
    hour    => 4,
    require => Package['ldap-git-backup'];
  }

  # Use the puppet cron task instead of the packaged cron script for more
  # configurability and similarity with the kerberos-git-backup cron setup
  file {
    '/etc/cron.d/ldap-git-backup':
      ensure => absent;
  }

  # Pushing to GitHub is disabled for dev-* hosts to prevent duplicate backups
  if $::hostname !~ /^dev-/ {
    # GitHub deploy hook and key
    file {
      '/var/backups/ldap/.git/hooks/post-commit':
        content => "git push -q git@github.com:ocf/ldap master\n",
        mode    => '0755',
        require => [Package['ldap-git-backup'], File['/root/.ssh/id_rsa']];

      '/root/.ssh':
        ensure => directory,
        mode   => '0700';

      '/root/.ssh/id_rsa':
        source => 'puppet:///private/id_rsa',
        mode   => '0600';

      # This is to stop backups from sending emails every time a new IP is used
      # See rt#4724 for more information
      '/root/.ssh/known_hosts':
        source => 'puppet:///modules/ocf_ldap/github_known_hosts';
    }
  }

  cron { 'ldap-lint':
    command  => '/opt/share/utils/sbin/ldap-lint',
    user     => root,
    special  => 'daily',
    require  => Vcsrepo['/opt/share/utils'];
  }

  ocf::munin::plugin { 'slapd-open-files':
    source => 'puppet:///modules/ocf_ldap/munin/slapd-open-files',
    user   => root,
  }
}
