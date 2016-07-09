class ocf_irc {
  include ocf_ssl
  include ocf_irc::slack

  package {
    [
      'anope',
      'inspircd',
    ]:;
  }

  # Need to run these for users to restore their options after import:
  # `/ns saset autoop <nick> on`, `/ns saset kill <nick> quick`,
  # `/ns saset secure <nick> on`, `/ns saset private <nick> on`
  # Options set for users on existing IRC: Protection, Security, Private, Auto-op
  #
  # Also need to enable these options for all channels:
  # `/cs set keeptopic #<channel> on`, `/cs set peace #<channel> on`,
  # `/cs set signkick #<channel> on`, `/cs set secure #<channel> on`,
  # `/cs set securefounder #<channel> on`, `/cs set noexpire #<channel> on`
  # Needed options: Topic Retention, Peace, Secure, Secure Founder, Signed kicks, No expire
  #
  # Also fix the AOP lists, they are wrong. Same likely with the SOP lists, etc.

  # TODO: Make the Slack channel purposes update when the IRC topic updates!
  # API: https://api.slack.com/methods/channels.setTopic

  service { 'anope':
    ensure  => 'running',
    require => [Package['anope'], Service['inspircd']],
  }

  service { 'inspircd':
    ensure  => 'running',
    restart => 'service inspircd reload',
    require => Package['inspircd'],
  }

  user { 'irc':
    groups => 'ssl-cert',
  }

  # TODO: Restrict permissions on config files with passwords!
  $irc_passwords = parsejson(file("/opt/puppet/shares/private/${::hostname}/irc-passwords"))

  file {
    # Core InspIRCd files
    '/etc/default/inspircd':
      content => 'INSPIRCD_ENABLED=1',
      require => Package['inspircd'],
      notify  => Service['inspircd'];

    '/etc/inspircd/inspircd.conf':
      content => template('ocf_irc/inspircd.conf.erb'),
      mode    => '0640',
      owner   => 'irc',
      group   => 'irc',
      require => Package['inspircd'],
      notify  => Service['inspircd'];

    '/etc/inspircd/inspircd.motd':
      source  => 'puppet:///modules/ocf_irc/ircd.motd',
      owner   => 'irc',
      group   => 'irc',
      require => Package['inspircd'],
      notify  => Service['inspircd'];


    # Core anope files
    '/etc/default/anope':
      content => 'START=yes',
      require => Package['anope'],
      notify  => Service['anope'];

    '/etc/anope/services.conf':
      content => template('ocf_irc/services.conf.erb'),
      mode    => '0640',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];

    '/etc/anope/services.motd':
      content => 'Welcome to OCF IRC Services!',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];


    # Anope service files
    '/etc/anope/chanserv.conf':
      source  => 'puppet:///modules/ocf_irc/anope/chanserv.conf',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];

    '/etc/anope/global.conf':
      source  => 'puppet:///modules/ocf_irc/anope/global.conf',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];

    '/etc/anope/nickserv.conf':
      source  => 'puppet:///modules/ocf_irc/anope/nickserv.conf',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];

    '/etc/anope/operserv.conf':
      source  => 'puppet:///modules/ocf_irc/anope/operserv.conf',
      group   => 'irc',
      require => Package['anope'],
      notify  => Service['anope'];
  }
}
