class ocf_irc::services {
  package { 'anope':; }

  ocf::systemd::service { 'anope':
    source  => 'puppet:///modules/ocf_irc/anope.service',
    require => Package['anope'],
  }

  $irc_creds = lookup('irc_creds')
  $root_nicks = ['waf', 'nattofriends', 'ckuehl', 'jvperrin', 'mattmcal', 'abizer', 'dkessler']

  file {
    default:
      require => Package['anope'],
      notify  => Service['anope'],
      owner   => irc,
      group   => irc;

    '/etc/default/anope':
      content => "START=yes\n",
      owner   => root,
      group   => root;

    '/etc/anope/services.conf':
      content   => template('ocf_irc/services.conf.erb'),
      mode      => '0640',
      show_diff => false;

    '/etc/anope/services.motd':
      content => "Welcome to OCF IRC Services!\n";

    '/etc/anope':
      ensure  => directory,
      recurse => true,
      source  => 'puppet:///modules/ocf_irc/anope';
  }

  # Delete all logs older than 14 days.
  # This would be better with logrotate, but the log files contain the date in
  # their name, which logrotate doesn't handle very well.
  cron { 'clean-anope-logs':
    command => 'find /var/log/anope/ -mtime +14 -delete > /dev/null',
    user    => 'irc',
    special => 'daily',
    require => Package['anope'],
  }
}
