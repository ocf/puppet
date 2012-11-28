class ocf::common::postfix {

  # remove exim
  package { [ 'exim4', 'exim4-base', 'exim4-config', 'exim4-daemon-light' ]:
    ensure => purged
  }

  # install postfix
  package { [ 'postfix', 'bsd-mailx' ]:
    require => Package[ 'exim4', 'exim4-base', 'exim4-config', 'exim4-daemon-light' ]
  }

  # provide mail configuration files
  file {
    '/etc/mailname':
      content  => 'ocf.berkeley.edu',
      require  => Package['postfix'];
    '/etc/postfix/main.cf':
      content  => template('ocf/common/main.cf.erb'),
      require  => Package['postfix'];
    '/etc/postfix/master.cf':
      source   => 'puppet:///modules/ocf/common/master.cf',
      require  => Package['postfix']
  }

  # start and restart postfix
  service { 'postfix':
    subscribe => File[ '/etc/mailname', '/etc/postfix/main.cf', '/etc/postfix/master.cf' ],
    require   => Package['postfix']
  }

}
