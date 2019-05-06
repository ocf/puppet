class ocf::node_exporter {
  file { '/srv/prometheus':
    ensure => directory;
  }

  file { '/srv/prometheus/ocf-environment.prom':
    content => template('ocf/environment.prom.erb'),
  }

  if $::lsbdistid != 'Raspbian' {
    include prometheus::node_exporter
  }
}
