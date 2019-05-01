class ocf::node_exporter {
  file { '/srv/prometheus':
    ensure => directory;
  }

  if $::lsbdistid != 'Raspbian' {
    include prometheus::node_exporter
  }
}
