class common::munin( $master = false ) {
  package {
    ['munin-node', 'munin-plugins-core', 'munin-plugins-extra', 'munin-libvirt-plugins']:;
  }

  service { 'munin-node':
    require => Package['munin-node'];
  }

  file { '/etc/munin/munin-node.conf':
    source  => 'puppet:///modules/common/munin/munin-node.conf',
    mode    => 644,
    notify  => Service['munin-node'],
    require => Package['munin-node'];
  }


  if $master {
    package {
      ['munin', 'nmap']:;
    }

    service { 'munin':
      require => Package['munin'];
    }

    file {
      '/etc/munin/munin.conf':
        source  => 'puppet:///modules/common/munin/munin.conf',
        mode    => 644,
        notify  => Service['munin'],
        require => Package['munin'];
      '/usr/local/bin/gen-munin-nodes':
        source  => 'puppet:///modules/common/munin/gen-munin-nodes',
        mode    => 755;
    }

    cron { 'gen-munin-nodes':
      command => '/usr/local/bin/gen-munin-nodes > /etc/munin/munin-conf.d/nodes',
      special => 'hourly',
      notify  => Service['munin'];
    }
  }

}
