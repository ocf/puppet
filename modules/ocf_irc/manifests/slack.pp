class ocf_irc::slack {
  package {
    [
      'nodejs-legacy',
      'slack-irc',
    ]:;
  }

  $slack_token = file("/opt/puppet/shares/private/${::hostname}/slack-bot-token")
  validate_re($slack_token, '^xoxb-[0-9]{11}-[a-zA-Z0-9]{24}$', 'Bad Slack bot token')

  file {
    '/etc/slack-irc':
      ensure => directory;

    '/etc/slack-irc/config.json':
      content => template('ocf_irc/slack-irc-conf.json.erb'),
      mode    => '0600',
      require => File['/etc/slack-irc'],
      notify  => Service['slack-irc'];
  }

  ocf::systemd::service { 'slack-irc':
    source  => 'puppet:///modules/ocf_irc/slack-irc.service',
    require => [
      Package['slack-irc'],
      File['/etc/slack-irc/config.json'],
    ],
  }
}
