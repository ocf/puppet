class ocf::common::postfix {

  # remove exim
  package { ['exim4', 'exim4-base', 'exim4-config', 'exim4-daemon-light']:
    ensure => purged,
    before => Package['postfix'],
  }

  package {
    'postfix':
    ;
    'bsd-mailx':
      require => Package['postfix'],
    ;
  }

  # disable incoming TCP/IP connections
  augeas { '/etc/postfix/master.cf':
    context => "/files/etc/postfix/master.cf",
    changes => "rm *[type='inet']",
    notify  => Service['postfix'],
    require => Package['postfix'],
  }

  # mail configuration
  file {
    '/etc/mailname':
      content => 'ocf.berkeley.edu',
    ;
    '/etc/postfix/main.cf':
      source  => 'puppet:///modules/ocf/common/postfix/main.cf',
      notify  => Service['postfix'],
      require => Package['postfix'],
    ;
  }

  service { 'postfix':
    require => Package['postfix'],
  }

}
