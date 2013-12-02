class typhoon {

  service { 'postfix': }

  file {
    '/etc/postfix/main.cf':
      source => 'puppet:///modules/typhoon/postfix/main.cf',
      notify => Service['postfix'];
    '/etc/postfix/master.cf':
      source => 'puppet:///modules/typhoon/postfix/master.cf',
      notify => Service['postfix'];
  }
}
