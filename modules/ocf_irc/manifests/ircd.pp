class ocf_irc::ircd {
  package { 'inspircd':; }

  service { 'inspircd':
    restart   => 'service inspircd reload',
    enable    => true,
    require   => Package['inspircd'],
    subscribe => Ocf::Ssl::Bundle[$::fqdn],
  } ->
  cron { 'reload-irc-cert':
    command => 'chronic /usr/local/bin/reload-ssl.sh /etc/inspircd/reload_pass',
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
      require => Package['inspircd'],
    }
  }

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
      content   => template('ocf_irc/inspircd.conf.erb'),
      mode      => '0640',
      show_diff => false;

    '/etc/inspircd/inspircd.motd':
      source  => 'puppet:///modules/ocf_irc/ircd.motd';

    '/usr/local/bin/reload-ssl.sh':
      source => 'puppet:///modules/ocf_irc/reload-ssl.sh',
      mode   => '0755';

    '/etc/inspircd/reload_pass':
      content   => $irc_creds['cert_reload_password'],
      mode      => '0640',
      show_diff => false;
  }
}
