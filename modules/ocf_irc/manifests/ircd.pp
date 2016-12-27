class ocf_irc::ircd {
  package { 'inspircd':; }

  service { 'inspircd':
    restart => 'service inspircd reload',
    enable  => true,
    require => Package['inspircd'],
  }

  ocf::systemd::override { 'start-inspircd-before-anope':
    service => 'inspircd',
    content => "[Unit]\nBefore=anope.service",
    require => Package['inspircd', 'anope'],
    before  => Service['inspircd'],
  }

  $passwords = parsejson(file("/opt/puppet/shares/private/${::hostname}/ircd-passwords"))

  file {
    default:
      require => Package['inspircd'],
      notify  => Service['inspircd'],
      owner   => irc,
      group   => irc;

    '/etc/default/inspircd':
      content => "INSPIRCD_ENABLED=1\n",
      owner   => root,
      group   => root;

    '/etc/inspircd/inspircd.conf':
      content => template('ocf_irc/inspircd.conf.erb'),
      mode    => '0640';

    '/etc/inspircd/inspircd.motd':
      source  => 'puppet:///modules/ocf_irc/ircd.motd';
  }
}
