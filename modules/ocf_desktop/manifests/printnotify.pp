class ocf_desktop::printnotify {
  user { 'ocfbroker':
    ensure => present,
    shell  => '/bin/false',
    system =>  true,
  }

  # enable regular users to run notification script as ocfbroker
  file { '/etc/sudoers.d/broker':
    content => "ALL ALL=(ocfbroker) NOPASSWD: /opt/share/puppet/print-notify-handler\n",
    require => User['ocfbroker'],
  }

  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('broker::redis::password'))

  file {
    '/opt/share/broker':
      ensure => directory,
      mode   => '0500',
      owner  => 'ocfbroker';

    '/opt/share/broker/broker.conf':
      content   => template('ocf/broker/broker.conf.erb'),
      mode      => '0400',
      owner     => 'ocfbroker',
      show_diff => false;
    }
}
