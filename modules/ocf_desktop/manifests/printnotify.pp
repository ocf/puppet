class ocf_desktop::printnotify {
  user { 'ocf_broker':
    ensure => present,
    shell  => '/bin/false',
  }

  # enable regular users to run notification script as ocf_broker
  file { '/etc/sudoers.d/broker':
    content => "ALL ALL=(ocf_broker) NOPASSWD: /opt/share/puppet/print-notify-real\n",
    require =>  User['ocf_broker'],
  }

  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('broker::redis::password'))

  file {
    '/opt/share/broker':
      ensure => directory,
      mode   => '0500',
      owner  => 'ocf_broker';

    '/opt/share/broker/broker.conf':
      content => template('ocf/broker.conf.erb'),
      mode    => '0400',
      owner   => 'ocf_broker';
    }
}
