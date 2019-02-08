class ocf::nodeexporter {
  class { 'prometheus::node_exporter':
    version => '0.17.0',
  }
}
