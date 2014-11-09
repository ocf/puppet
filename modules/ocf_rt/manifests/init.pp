class ocf_rt {
  include ocf_ssl

  service { 'postfix':; }

  file {
    '/etc/postfix/main.cf':
      source => 'puppet:///modules/ocf_rt/postfix/main.cf',
      notify => Service['postfix'];
    '/etc/postfix/master.cf':
      source => 'puppet:///modules/ocf_rt/postfix/master.cf',
      notify => Service['postfix'];
  }
}
