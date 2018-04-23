class ocf_desktop::printnotify {
  user { 'ocfbroker':
    ensure => present,
    shell  => '/bin/false',
  }

  # enable regular users to run notification script as ocfbroker
  file { '/etc/sudoers.d/broker':
    content => "ALL ALL=(ocfbroker) NOPASSWD: /opt/share/puppet/print-notify-real\n\
ALL ALL=(ocfbroker) NOPASSWD: /bin/kill\n",
    require =>  User['ocfbroker'],
  }

  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('broker::redis::password'))

  file {
    '/opt/share/broker':
      ensure => directory,
      mode   => '0500',
      owner  => 'ocfbroker';

    '/opt/share/broker/broker.conf':
      content => template('ocf/broker/broker.conf.erb'),
      mode    => '0400',
      owner   => 'ocfbroker';
    }
}
