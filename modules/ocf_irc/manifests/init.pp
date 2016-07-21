class ocf_irc {
  include ocf_ssl
  include ocf_irc::ircd
  include ocf_irc::services
  include ocf_irc::nodejs::slack
  include ocf_irc::nodejs::webirc

  class { 'ocf_irc::nodejs::apt':
    stage => first,
  }

  # Make the irc user able to read the certs for running the IRCd with SSL
  user { 'irc':
    groups  => 'ssl-cert',
    require => [Package['inspircd'], Package['ssl-cert']],
  }
}
