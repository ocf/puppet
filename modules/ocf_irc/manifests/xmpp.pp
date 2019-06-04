class ocf_irc::xmpp {
  # lua-dbi-mysql is needed to connect to MySQL
  #package { ['lua-dbi-mysql']: }

  # When upgrading to buster, these can be installed from the regular buster
  # repo
  ocf::repackage {
    'lua-dbi-common':
      backport_on => ['stretch'];

    'lua-dbi-mysql':
      backport_on => ['stretch'];

    'prosody':
      backport_on => ['stretch'];

    'prosody-modules':
      backport_on => ['stretch'];
  }

  service { 'prosody':
    enable    => true,
    require   => Package['prosody'],
    subscribe => Ocf::Ssl::Bundle[$::fqdn],
  }

  # Make the prosody user able to read the certs
  user { 'prosody':
    groups  => 'ssl-cert',
    require => [Package['prosody'], Package['ssl-cert']],
  }

  ocf::firewall::firewall46 {
    '101 allow xmpp':
      opts   => {
        chain  => 'PUPPET-INPUT',
        proto  => 'tcp',
        dport  => [5222, 5269],
        action => 'accept',
      }
  }

  $vhost_name = $::host_env ? {
    'dev'  => 'dev-xmpp.ocf.berkeley.edu',
    'prod' => 'ocf.berkeley.edu',
  }

  $mysql_password = lookup('xmpp::prosody_mysql_password')

  file {
    '/etc/prosody/prosody.cfg.lua':
      content   => template('ocf_irc/prosody.cfg.lua.erb'),
      mode      => '0600',
      show_diff => false,
      require   => Package['prosody'],
      notify    => Service['prosody'],
      owner     => prosody,
      group     => prosody;
  }
}
