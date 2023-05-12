class ocf_irc::biboumi {
  ocf::repackage { 'biboumi':
    backport_on => ['stretch'],
    require     => Package['prosody'],
  }

  service { 'biboumi':
    enable  => true,
    require => Package['biboumi'],
  }

  $irc_server = $facts['host_env'] ? {
    'dev'  => 'dev-irc.ocf.berkeley.edu',
    'prod' => 'irc.ocf.berkeley.edu',
  }

  $psql_user = $facts['host_env'] ? {
    'dev'  => 'ocfdevbiboumi',
    'prod' => 'ocfbiboumi',
  }

  $psql_password = $facts['host_env'] ? {
    'dev'  => lookup('xmpp::dev_biboumi_psql_password'),
    'prod' => lookup('xmpp::biboumi_psql_password'),
  }

  $component_password = $facts['host_env'] ? {
    'dev'  => lookup('xmpp::dev_biboumi_component_password'),
    'prod' => lookup('xmpp::biboumi_component_password'),
  }

  file {
    '/etc/biboumi/biboumi.cfg':
      content   => template('ocf_irc/biboumi.cfg.erb'),
      mode      => '0600',
      show_diff => false,
      require   => Package['biboumi'],
      notify    => Service['biboumi'],
      owner     => '_biboumi';

  }
}
