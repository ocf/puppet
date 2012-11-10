class ocf::common::zabbix {

  # install zabbix
  package { 'zabbix-agent': }

  file {
    # provide zabbix config
    '/etc/zabbix/zabbix_agentd.conf':
      source  => 'puppet:///modules/ocf/common/zabbix_agentd.conf',
      require => Package[ 'zabbix-agent' ];
    # provide newer version of zabbix binary
    #'/usr/sbin/zabbix_agentd':
    #  mode    => '0755',
    #  backup  => false,
    #  source  => 'puppet:///contrib/common/zabbix_agentd',
    #  require => Package[ 'zabbix-agent' ];
  }

  # restart zabbix
  service { 'zabbix-agent':
    subscribe => [ Package['zabbix-agent'], File[ '/etc/zabbix/zabbix_agentd.conf' ] ]
    #subscribe => [ Package['zabbix-agent'], File[ '/etc/zabbix/zabbix_agentd.conf', '/usr/sbin/zabbix_agentd' ] ]
  }

}
