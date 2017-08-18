class ocf_irc {
  include ocf_ssl::default_bundle
  include ocf_irc::ircd
  include ocf_irc::services
  include ocf_irc::nodejs::webirc
  include ocf_irc::znc

  class { 'ocf_irc::nodejs::apt':
    stage => first,
  }

  # Make the irc user able to read the certs for running the IRCd with SSL
  user { 'irc':
    groups  => 'ssl-cert',
    require => [Package['inspircd'], Package['ssl-cert']],
  }
}
