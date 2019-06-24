class ocf_irc {
  include ocf_irc::biboumi
  include ocf_irc::ircd
  include ocf_irc::services
  include ocf_irc::webirc
  include ocf_irc::xmpp
  include ocf_irc::znc

  # The prod server also needs a cert for ocf.berkeley.edu, since we use XMPP
  # domain delegation. See https://prosody.im/doc/certificates#which_domain
  if $::host_env == 'prod' {
    ocf::ssl::bundle { $::fqdn:
      domains =>   ocf::get_host_fqdns() + ocf::get_host_fqdns('ocf.io') + ['ocf.berkeley.edu'],
    }
  } else {
    ocf::ssl::bundle { $::fqdn:
      domains =>   ocf::get_host_fqdns() + ocf::get_host_fqdns('ocf.io'),
    }
  }

  # Make the irc user able to read the certs for running the IRCd with SSL
  user { 'irc':
    groups  => 'ssl-cert',
    require => [Package['inspircd'], Package['ssl-cert']],
  }

  # Allow HTTP and HTTPS
  include ocf::firewall::allow_web

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
