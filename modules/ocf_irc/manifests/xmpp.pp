class ocf_irc::xmpp {
  # When upgrading to buster, these can be installed from the regular buster
  # repo
  if $::lsbdistcodename != 'buster' {
    ocf::repackage {
      # lua-dbi-mysql is needed to connect to MySQL
      'lua-dbi-common':
        backport_on => ['stretch'];

      'lua-dbi-mysql':
        backport_on => ['stretch'];

      'prosody':
        backport_on => ['stretch'];

      'prosody-modules':
        backport_on => ['stretch'];
    }
  } else {
    package {
      [
        'prosody',
        'prosody-modules',
        'lua-dbi-common',
        'lua-dbi-mysql'
      ]:;
    }
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
    # We use an SRV record in our DNS configuration so this host actually points
    # to the XMPP server.
    'prod' => 'ocf.berkeley.edu',
  }

  # The subdomain used for Multi-User Chats (MUCs)
  $muc_name = $::host_env ? {
    # This doesn't resolve in DNS, but it doesn't matter since this won't be
    # exposed publicly. See https://prosody.im/doc/chatrooms#dns
    'dev'  => 'dev-xmpp-muc.ocf.berkeley.edu',
    'prod' => 'xmpp.ocf.berkeley.edu',
  }

  $irc_server = $::host_env ? {
    'dev'  => 'dev-irc.ocf.berkeley.edu',
    'prod' =>  'irc.ocf.berkeley.edu',
  }

  $mysql_password = lookup('xmpp::prosody_mysql_password')

  $component_password = $::host_env ? {
    'dev'  => lookup('xmpp::dev_biboumi_component_password'),
    'prod' =>  lookup('xmpp::biboumi_component_password'),
  }

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
