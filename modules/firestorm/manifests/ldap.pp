class firestorm::ldap {
  package { 'slapd':; }

  service { 'slapd':
    subscribe => File[
      '/etc/ldap/slapd.conf',
      '/etc/ldap/schema/ocf.schema',
      '/etc/default/slapd',
      '/etc/ldap/sasl2/slapd.conf'];
  }

  file {
    '/etc/ldap/slapd.conf':
      source  => 'puppet:///modules/firestorm/slapd.conf',
      require => Package['slapd'];

    '/etc/ldap/schema/ocf.schema':
      source  => 'puppet:///modules/firestorm/ocf.schema',
      require => Package['slapd'];

    '/etc/ldap/schema/puppet.schema':
      source  => 'puppet:///contrib/local/firestorm/puppet.schema',
      require => Package['slapd'];

    '/etc/default/slapd':
      source  => 'puppet:///modules/firestorm/slapd-defaults',
      require => Package['slapd', 'openssl'];

    '/etc/ldap/sasl2/slapd.conf':
      source  => 'puppet:///modules/firestorm/sasl2-slapd',
      require => Package['slapd', 'libsasl2-modules-gssapi-mit'];

    '/etc/ldap/krb5.keytab':
      source  => 'puppet:///private/krb5-ldap.keytab',
      owner   => openldap,
      group   => openldap,
      mode    => '0600',
      require => Package['slapd', 'heimdal-clients'];
  }

  # daily git backup
  if $::hostname == 'firestorm' {
    package { 'ldap-git-backup':; }

    cron { 'ldap-git-backup':
      command => '/usr/sbin/ldap-git-backup',
      minute  => 0,
      hour    => 4,
      require => Package['ldap-git-backup'];
    }

    # GitHub deploy hook and key
    file {
      '/var/backups/ldap/.git/hooks/post-commit':
        content => "git push -q git@github.com:ocf/ldap\n",
        mode    => '0755',
        require => [Package['ldap-git-backup'], File['/root/.ssh/id_rsa']];

      '/root/.ssh':
        ensure => directory,
        mode   => '0700';

      '/root/.ssh/id_rsa':
        source => 'puppet:///private/id_rsa',
        mode   => '0600';
    }
  }
}
