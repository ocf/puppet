class ocf_mail {
  include ocf_ssl::default_bundle
  include ocf_mail::firewall_input
  include ocf_mail::spam
  include ocf_mail::site_ocf
  include ocf_mail::site_vhost

  package { ['postfix']:; }

  service { 'postfix':
    require => Package['postfix'],
  }
  user { 'ocfmail':
    ensure  => present,
    name    => ocfmail,
    gid     => ocfmail,
    groups  => [sys],
    home    => '/var/mail',
    shell   => '/bin/false',
    system  => true,
    require => Group['ocfmail'],
  }

  group { 'ocfmail':
    ensure => present,
    name   => ocfmail,
    system => true,
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
}
