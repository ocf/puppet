class ocf_mail {
  include ocf::ssl::default

  include ocf_mail::spam
  include ocf_mail::site_ocf
  include ocf_mail::site_vhost

  package { ['postfix']:; }

  service { 'postfix':
    require   => Package['postfix'],
    subscribe => Class['ocf::ssl::default'],
  }

  user { 'ocfmail':
    ensure  => present,
    name    => ocfmail,
    gid     => ocfmail,
    groups  => [sys],
    home    => '/var/mail',
    shell   => '/bin/false',
    require => Group['ocfmail'],
  }

  group { 'ocfmail':
    ensure => present,
    name   => ocfmail,
  }

  file { '/etc/postfix/main.cf':
    mode    => '0644',
    content => template('ocf_mail/postfix/main.cf.erb'),
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # Require authentication for SMTP submission, even if within the OCF.
  # Otherwise, users can spoof each other on port 587
  augeas { '/etc/postfix/master.cf':
    context => '/files/etc/postfix/master.cf',
    changes => [
      'set submission/command "smtpd
          -o syslog_name=postfix/submission
          -o smtpd_sasl_auth_enable=yes
          -o smtpd_recipient_restrictions=permit_sasl_authenticated,reject"',
    ],
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  ocf::firewall::firewall46 {
    '101 allow submission':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 587,
        action => 'accept',
      };

    '102 allow smtp':
      opts => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => 25,
        action => 'accept',
      };
  }

  # Backported from sid
  package { ['prometheus-postfix-exporter']:; }
}
