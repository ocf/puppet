class ocf::node_exporter {
  file { '/srv/prometheus':
    ensure => directory;
  }

  file { '/srv/prometheus/ocf-environment.prom':
    content => template('ocf/environment.prom.erb'),
  }

  if $::lsbdistid != 'Raspbian' {
    class { 'prometheus::node_exporter':
      collectors_enable => ['systemd'],
      extra_options     => '--collector.systemd.unit-whitelist ".+\.(service|timer)"',
    }
  }
}
