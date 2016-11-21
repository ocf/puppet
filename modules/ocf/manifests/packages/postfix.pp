class ocf::packages::postfix {
  # remove exim
  package { ['exim4', 'exim4-base', 'exim4-config', 'exim4-daemon-light']:
    ensure => purged,
    before => Package['postfix'],
  }

  if !tagged('ocf_mail') {
    package {
      ['postfix', 'bsd-mailx']:;
    }

    # disable incoming TCP/IP connections
    augeas { '/etc/postfix/master.cf':
      context => '/files/etc/postfix/master.cf',
      changes => 'rm *[type=\'inet\']',
      notify  => Service['postfix'],
      require => Package['postfix'],
    }

    # mail configuration
    file {
      '/etc/mailname':
        content => "ocf.berkeley.edu\n";

      '/etc/postfix/main.cf':
        source  => 'puppet:///modules/ocf/postfix/main.cf',
        notify  => Service['postfix'],
        require => Package['postfix'];
    }

    service { 'postfix':
      require => Package['postfix'],
    }
  }
}
