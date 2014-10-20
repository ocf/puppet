# munin master config
class ocf_stats::munin {
  package {
    ['munin', 'nmap']:;
  }

  service { 'munin':
    require => Package['munin'];
  }

  file {
    '/etc/munin/munin.conf':
      source  => 'puppet:///modules/common/munin/munin.conf',
      mode    => '0644',
      notify  => Service['munin'],
      require => Package['munin'];
    '/usr/local/bin/gen-munin-nodes':
      source  => 'puppet:///modules/common/munin/gen-munin-nodes',
      mode    => '0755';
  }

  cron { 'gen-munin-nodes':
    command => '/usr/local/bin/gen-munin-nodes > /etc/munin/munin-conf.d/nodes',
    special => 'hourly',
    notify  => Service['munin'];
  }
}
