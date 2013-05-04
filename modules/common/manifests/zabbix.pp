class common::zabbix {

  package { 'zabbix-agent':
    ensure => purged,
  }

  file {
    '/etc/zabbix':
      ensure  => absent,
      recurse => true,
      backup  => false,
    ;
    '/usr/sbin/zabbix_agentd':
      ensure  => absent,
    ;
  }

}
