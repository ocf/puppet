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

  # Allow HTTP and HTTPS
  include ocf::firewall::allow_http

  # Allow IRC server (SSL only)
  ocf::firewall::firewall46 {
    '101 allow irc':
    opts => {
      chain  => 'PUPPET-INPUT',
      proto  => 'tcp',
      dport  => 6697,
      action => 'accept',
    };
  }

  # Allow ZNC server
  ocf::firewall::firewall46 {
    '101 allow znc':
    opts => {
      chain  => 'PUPPET-INPUT',
      proto  => 'tcp',
      dport  => 4095,
      action => 'accept',
    };
  }
}
