class typhoon {

  service { 'postfix': }

  file {
    '/etc/postfix/main.cf':
      source => 'puppet:///modules/typhoon/postfix/main.cf',
      notify => Service['postfix'];
    '/etc/postfix/master.cf':
      source => 'puppet:///modules/typhoon/postfix/master.cf',
      notify => Service['postfix'];
    '/etc/ssl/private/rt_ocf_berkeley_edu.crt':
      mode   => 444,
      source => 'puppet:///private/typhoon.ocf.berkeley.edu.crt';
    '/etc/ssl/private/rt_ocf_berkeley_edu.key':
      owner  => root,
      mode   => 400,
      source => 'puppet:///private/typhoon.ocf.berkeley.edu.key';
    '/etc/ssl/private/rt_ocf_berkeley_edu.chained.crt':
      mode   => 444,
      source => 'puppet:///private/typhoon.ocf.berkeley.edu-chain.crt';
  }
}
