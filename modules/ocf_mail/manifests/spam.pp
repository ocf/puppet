# The ocf_mail::spam class provides badness filtering common to the various
# site configurations, including:
#
#  - milter configuration
#  - clamav virus scanning
#  - spamassassin
#  - postgrey (graylisting)
#  - policyd-weight (DNSBLs and more)
#  - basic metadata logging to /var/log/ocfmail.log
#
# It is designed to be included by site configurations.

class ocf_mail::spam {
  # badness filtering common to all site configurations

  package {
    ['clamav-milter', 'spamassassin', 'spamass-milter', 'postgrey',
    'policyd-weight']:;
  }

  service {
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
  }

  group {
    'spamd':
      ensure  => present,
      name    => 'spamd',
      system  => true;
  }

  file {
    '/etc/default/spamassassin':
      source  => 'puppet:///modules/ocf_mail/spam/spamass/spamassassin',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/etc/spamassassin/local.cf':
      source  => 'puppet:///modules/ocf_mail/spam/spamass/local.cf',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/etc/spamassassin/v310.pre':
      source  => 'puppet:///modules/ocf_mail/spam/spamass/v310.pre',
      notify  => Service['spamassassin'],
      require => Package['spamassassin'];
    '/var/lib/spamd':
      ensure  => directory,
      owner   => spamd,
      mode    => '0755',
      require => User['spamd'];
    '/etc/default/spamass-milter':
      source  => 'puppet:///modules/ocf_mail/spam/spamass/spamass-milter',
      notify  => Service['spamass-milter'],
      require => Package['spamass-milter'];
    '/var/spool/postfix/clamav':
      ensure  => directory,
      owner   => clamav,
      group   => root;
    '/etc/clamav/clamav-milter.conf':
      source  => 'puppet:///modules/ocf_mail/spam/clamav/clamav-milter.conf',
      notify  => Service['clamav-milter'],
      require => Package['clamav-milter'];
    '/etc/default/postgrey':
      source  => 'puppet:///modules/ocf_mail/spam/postgrey/postgrey',
      notify  => Service['postgrey'],
      require => Package['postgrey'];
    '/etc/policyd-weight.conf':
      source  => 'puppet:///modules/ocf_mail/spam/policyd-weight/policyd-weight.conf',
      notify  => Service['policyd-weight'],
      require => Package['policyd-weight'];

    # logging
    '/usr/local/bin/log-mail':
      source => 'puppet:///modules/ocf_mail/spam/logging/log-mail',
      mode   => '0755';

    '/usr/local/bin/examine-mail-log':
      source => 'puppet:///modules/ocf_mail/spam/logging/examine-mail-log',
      mode   => '0755';

    '/var/log/ocfmail.log':
      ensure => file,
      owner  => ocfmail,
      group  => ocfmail,
      mode   => '0600';

    '/etc/logrotate.d/mail-log':
      source => 'puppet:///modules/ocf_mail/spam/logging/logrotate';
  }

  cron { 'examine-mail-log':
    command     => '/usr/local/bin/examine-mail-log < /var/log/ocfmail.log',
    user        => ocfmail,
    environment => 'MAILTO=root',
    hour        => '05',
    minute      => '00';
  }
}
