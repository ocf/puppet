class ocf_irc::ircd {
  ocf::repackage { 'inspircd':
      backport_on =>  ['buster'],
  }

  service { 'inspircd':
    restart   => 'service inspircd reload',
    enable    => true,
    require   => Ocf::Repackage['inspircd'],
    subscribe => Ocf::Ssl::Bundle[$::fqdn],
  } ->
  cron { 'reload-irc-cert':
    command => 'chronic /usr/local/bin/reload-ssl.sh',
    hour    => 0,
    minute  => 0,
    weekday => 0,
    user    => 'irc',
  }

  $irc_creds = lookup('irc_creds')

  if $::lsbdistcodename == 'buster' {
    # Disable the AppArmor profile for inspircd, since it prevents us from
    # accessing the necessary TLS certs
    file { '/etc/apparmor.d/disable/usr.sbin.inspircd':
      ensure  => 'link',
      target  => '/etc/apparmor.d/usr.sbin.inspircd',
      require => Ocf::Repackage['inspircd'],
    }
  }

  file {
    default:
      require => Ocf::Repackage['inspircd'],
      notify  => Service['inspircd'],
      owner   => irc,
      group   => irc;

    '/etc/default/inspircd':
      content => "INSPIRCD_ENABLED=1\n",
      owner   => root,
      group   => root;

    '/etc/inspircd/inspircd.conf':
      content   => template('ocf_irc/inspircd.conf.erb'),
      mode      => '0640',
      show_diff => false;

    '/etc/inspircd/inspircd.motd':
      source  => 'puppet:///modules/ocf_irc/ircd.motd';

    '/usr/local/bin/reload-ssl.sh':
      source => 'puppet:///modules/ocf_irc/reload-ssl.sh',
      mode   => '0755';
  }

  ocf::systemd::override { 'inspircd-group-restart':
    unit   => 'inspircd.service',
    source => 'puppet:///modules/ocf_irc/inspircd.service.d/override.conf';
  }
}
