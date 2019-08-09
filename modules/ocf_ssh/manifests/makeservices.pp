class ocf_ssh::makeservices {
  user { 'ocfmakexmpp':
    comment => 'OCF user to create XMPP accounts',
    shell   => '/bin/false',
  }

  # enable regular users to run makemysql.py as mysql
  file { '/etc/sudoers.d/makeservices':
    content => "ALL ALL=(mysql) NOPASSWD: /opt/share/utils/makeservices/makemysql-real\n",
  }

  # enable regular users to run makexmpp.py as ocfmakexmpp
  file { '/etc/sudoers.d/makexmpp':
    content => "ALL ALL=(ocfmakexmpp) NOPASSWD: /opt/share/utils/makeservices/makexmpp-real\n",
  }

  $mysql_root_password = lookup('ocf_mysql::root_password')
  $xmpp_root_password = lookup('xmpp::root_password')

  file {
    '/opt/share/makeservices':
      ensure => directory,
      mode   => '0700',
      owner  => 'mysql';

    '/opt/share/makeservices/makemysql.conf':
      content   => template('ocf_ssh/makemysql.conf.erb'),
      show_diff => false;

    '/opt/share/makexmpp':
      ensure => directory,
      mode   => '0700',
      owner  => 'ocfmakexmpp';

    '/opt/share/makexmpp/makexmpp.conf':
      content   => template('ocf_ssh/makexmpp.conf.erb'),
      show_diff => false;
  }
}
