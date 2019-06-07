class ocf_ssh::makeservices {
  user { 'ocfmakexmpp':
    comment => 'OCF user to create XMPP accounts',
    groups  => ['sys'],
    shell   => '/bin/false',
    system  => true,
  }

  # enable regular users to run makemysql.py as mysql
  file { '/etc/sudoers.d/makeservices':
    content => "ALL ALL=(mysql) NOPASSWD: /opt/share/utils/makeservices/makemysql-real\n",
  }

  # enable regular users to run makexmpp.py as ocfmakexmpp
  file { '/etc/sudoers.d/makexmpp':
    content => "ALL ALL=(ocfmakexmpp) NOPASSWD: /opt/share/utils/makeservices/makexmpp-real\n",
  }

  file {
    '/opt/share/makeservices':
      ensure => directory,
      mode   => '0700',
      owner  => 'mysql';

    '/opt/share/makeservices/makemysql.conf':
      source    => 'puppet:///private/makeservices/makemysql.conf',
      show_diff => false;

    '/opt/share/makexmpp':
      ensure => directory,
      mode   => '0700',
      owner  => 'ocfmakexmpp';

    '/opt/share/makexmpp/makexmpp.conf':
      source    => 'puppet:///private/makeservices/makexmpp.conf',
      show_diff => false;
  }
}
