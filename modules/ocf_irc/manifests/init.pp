class ocf_irc {
  include ocf_ssl::default_bundle
  include ocf_irc::ircd
  include ocf_irc::services
  include ocf_irc::webirc
  include ocf_irc::znc

  # Make the irc user able to read the certs for running the IRCd with SSL
  user { 'irc':
    groups  => 'ssl-cert',
    require => [Package['inspircd'], Package['ssl-cert']],
  }
}
